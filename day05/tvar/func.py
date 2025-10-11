import numpy as np
import pandas as pd
from numpy.linalg import lstsq, eigvals, inv, cholesky
import pandas as pd

def lagmat(Y, p):
    """
    Construye la matriz de regresores para VAR(p).
    Devuelve X (n x (1+k*p)) con intercepto y Ytrim (n x k) alineada, n = T-p.
    """
    T, k = Y.shape
    if T <= p:
        raise ValueError("T debe ser > p.")
    X = []
    for t in range(p, T):
        row = [1.0]
        for i in range(1, p+1):
            row.extend(Y[t-i, :])
        X.append(row)
    return np.asarray(X), Y[p:, :]

def select_var_lag(Y, pmax=6):
    """
    Selecciona p por BIC (y reporta AIC/BIC) para un VAR lineal.
    Retorna p_star y una tabla con criterios.
    """
    T, k = Y.shape
    results = []
    for p in range(1, pmax+1):
        X, Ytrim = lagmat(Y, p)
        B = lstsq(X, Ytrim, rcond=None)[0]   # (1+k*p) x k
        resid = Ytrim - X @ B                # (n x k)
        sse = float(np.sum(resid**2))
        n = len(Ytrim)
        k_params = B.size
        # Supuesto Gauss: log-like ~ -n*k/2 * log(sigma^2)
        sigma2 = sse / (n * k)
        bic = n * k * np.log(sigma2) + np.log(n) * k_params
        aic = n * k * np.log(sigma2) + 2 * k_params
        results.append((p, sse, aic, bic))
    df = pd.DataFrame(results, columns=["p","SSE","AIC","BIC"])
    p_star = int(df.loc[df["BIC"].idxmin(),"p"])
    return p_star, df

def companion_max_eig(B, k, p):
    """
    Máximo módulo de eigenvalor del compañero (estabilidad) para un VAR dado.
    B: (1+k*p) x k apilado (intercepto + bloques Ai transpuestos).
    """
    A = np.zeros((k*p, k*p))
    for i in range(p):
        Ai = B[1 + i*k : 1 + (i+1)*k, :].T  # k x k
        A[:k, i*k:(i+1)*k] = Ai
    if p > 1:
        A[k:, :-k] = np.eye(k*(p-1))
    return float(np.max(np.abs(eigvals(A))))

def aic_bic_from_resid(resid, n_params):
    """
    Métricas AIC/BIC a partir de residuales Ytrim - X@B (n x k).
    """
    n, k = resid.shape
    sse = float(np.sum(resid**2))
    sigma2 = sse / (n * k)
    aic = n * k * np.log(sigma2) + 2 * n_params
    bic = n * k * np.log(sigma2) + np.log(n) * n_params
    return sse, sigma2, aic, bic




# =========================
# 2) TVAR (estimación por grid en c) y test bootstrap
# =========================
def fit_tvar(Y, p, z_series, d=1, q_low=0.15, q_high=0.85, ngrid=61, min_frac=0.15):
    """
    Estima un TVAR de 2 regímenes con umbral c en z_{t-d}.
    - Busca c en cuantiles [q_low, q_high], exige fracción mínima min_frac por régimen.
    - OLS por régimen (todas las ecuaciones a la vez).
    Devuelve dict con c, B1,B2,Sigma1,Sigma2,resid, máscaras I1/I2, etc.
    """
    T, k = Y.shape
    if not (1 <= d < T):
        raise ValueError("El delay d debe ser >=1 y < T.")
    X, Ytrim = lagmat(Y, p)        # Ytrim corresponde a t = p..T-1 (n=T-p filas)
    n = len(Ytrim)
    # Alinear z_{t-d} con Ytrim: t=p..T-1  ->  índice de z va de (p-d) .. (T-1-d)
    z = z_series[p - d : T - d]
    if len(z) != n:
        raise RuntimeError("Alineación de z y Ytrim inconsistente. Revisa p y d.")
    qgrid = np.linspace(q_low, q_high, ngrid)
    cands = np.quantile(z, qgrid)
    min_obs = int(min_frac * n)

    best = None
    for c in cands:
        I2 = (z > c)              # régimen alto (z>c)
        I1 = ~I2                  # régimen bajo (z<=c)
        if I1.sum() < min_obs or I2.sum() < min_obs:
            continue
        B1 = lstsq(X[I1,:], Ytrim[I1,:], rcond=None)[0]
        B2 = lstsq(X[I2,:], Ytrim[I2,:], rcond=None)[0]
        resid = np.empty_like(Ytrim)
        resid[I1,:] = Ytrim[I1,:] - X[I1,:] @ B1
        resid[I2,:] = Ytrim[I2,:] - X[I2,:] @ B2
        sse = float(np.sum(resid**2))
        if (best is None) or (sse < best["sse"]):
            Sigma1 = (resid[I1,:].T @ resid[I1,:]) / I1.sum()
            Sigma2 = (resid[I2,:].T @ resid[I2,:]) / I2.sum()
            best = dict(c=c, B1=B1, B2=B2, Sigma1=Sigma1, Sigma2=Sigma2,
                        resid=resid, I1=I1, I2=I2, z=z, X=X, Ytrim=Ytrim, sse=sse)
    return best

def bootstrap_test_linear_vs_tvar(Y, p, B_lin, z_series, d=1, B=150, seed=1):
    """
    Test bootstrap de no linealidad: Δ = SSE_VAR - SSE_TVAR.
    - Re-muestrea residuales vectoriales del VAR lineal (preserva correlación cruzada).
    - Re-estima VAR y TVAR en cada réplica y computa Δ_b.
    p-valor ≈ Pr(Δ_b >= Δ_obs).
    """
    rng = np.random.default_rng(seed)
    X, Ytrim = lagmat(Y, p)
    U = Ytrim - X @ B_lin
    sse_lin_obs = float(np.sum(U**2))
    tvar_obs = fit_tvar(Y, p, z_series, d=d)
    sse_tvar_obs = tvar_obs["sse"]
    delta_obs = sse_lin_obs - sse_tvar_obs

    T, k = Y.shape
    deltas = np.empty(B)
    for b in range(B):
        draw_idx = rng.integers(0, U.shape[0], size=U.shape[0])
        U_star = U[draw_idx, :]  # residuales vectoriales con reemplazo
        # Generar serie bootstrap bajo el modelo lineal
        Y_star = np.zeros_like(Y)
        Y_star[:p, :] = Y[:p, :]  # condiciones iniciales
        for t in range(p, T):
            x = [1.0]
            for i in range(1, p+1):
                x.extend(Y_star[t-i, :])
            Y_star[t, :] = np.asarray(x) @ B_lin + U_star[t-p, :]
        # Re-estimar
        Xs, Ys = lagmat(Y_star, p)
        B_lin_b = lstsq(Xs, Ys, rcond=None)[0]
        sse_lin_b = float(np.sum((Ys - Xs @ B_lin_b)**2))
        tvar_b = fit_tvar(Y_star, p, z_series=Y_star[:, -1], d=d)  # umbral en la última col (spread)
        deltas[b] = sse_lin_b - tvar_b["sse"]

    pval = (np.sum(deltas >= delta_obs) + 1) / (B + 1)
    return delta_obs, deltas, pval

# =========================
# 3) GIRFs (Koop–Pesaran–Potter) con identificación por régimen
# =========================
def simulate_tvar_path(B1, B2, c, p, Y0, shocks_seq, Sigma1, Sigma2, d=1, seed=10, spread_col=-1):
    """
    Simula una trayectoria del TVAR aplicando shocks reducidos (u_t) determinísticos (shocks_seq).
    - shocks_seq: (H x k) con u_t añadidos a las innovaciones en cada paso.
    - Y0: bloque inicial (p x k).
    """
    rng = np.random.default_rng(seed)
    H, k = shocks_seq.shape
    Y_sim = np.zeros((H + p, k))
    Y_sim[:p, :] = Y0[-p:, :]
    for t in range(p, H + p):
        z = Y_sim[t - d, spread_col]
        B = B2 if (z > c) else B1
        Sigma = Sigma2 if (z > c) else Sigma1
        e = rng.multivariate_normal(np.zeros(k), Sigma) + shocks_seq[t-p, :]
        x = [1.0]
        for i in range(1, p+1):
            x.extend(Y_sim[t-i, :])
        Y_sim[t, :] = np.asarray(x) @ B + e
    return Y_sim

def tvar_girf(B1, B2, c, p, Sigma1, Sigma2, init_state, shock_var, horizon=20, R=300,
              shock_size=1.0, spread_col=-1, seed=99):
    """
    GIRF (Koop-Pesaran-Potter):
    GIRF(h) = E[y_{t+h} | shock_j, S0] - E[y_{t+h} | no shock, S0],
    con identificación Cholesky por régimen (P_s P_s' = Sigma_s), shock estructural en j.
    """
    k = Sigma1.shape[0]
    P1 = cholesky(Sigma1)
    P2 = cholesky(Sigma2)
    # Elegir P según el estado inicial (regla simple; ambas opciones son posibles)
    z0 = init_state[-1, spread_col]
    P_use = P2 if (z0 > c) else P1

    e0 = np.zeros(k); e0[shock_var] = shock_size      # shock estructural unitario
    u0 = P_use @ e0                                   # shock reducido equivalente

    diffs = np.zeros((horizon+1, k))
    for r in range(R):
        shocks_shock = np.zeros((horizon+1, k)); shocks_shock[0, :] = u0
        shocks_base  = np.zeros((horizon+1, k))
        Y_shock = simulate_tvar_path(B1, B2, c, p, init_state, shocks_shock, Sigma1, Sigma2,
                                     d=1, seed=seed+r, spread_col=spread_col)
        Y_base  = simulate_tvar_path(B1, B2, c, p, init_state, shocks_base,  Sigma1, Sigma2,
                                     d=1, seed=seed+r, spread_col=spread_col)
        diffs += (Y_shock[p:p+horizon+1, :] - Y_base[p:p+horizon+1, :])
    return diffs / R

# =========================
# 4) Empaques y visualización
# =========================
def unpack_B(B, k, p):
    """
    Devuelve dict con 'intercept' y bloques A1..Ap (cada Ai como k x k).
    """
    out = {"intercept": B[0, :]}
    for i in range(p):
        out[f"A{i+1}"] = B[1 + i*k : 1 + (i+1)*k, :].T
    return out

def pretty_print_coeffs(B, varnames, title):
    """
    Imprime intercepto y bloques Ai con etiquetas de variables.
    """
    k = len(varnames)
    p = (B.shape[0] - 1) // k
    Bu = unpack_B(B, k, p)
    print(f"\n=== {title} ===")
    print("Intercepto:", dict(zip(varnames, Bu["intercept"])))
    for i in range(1, p+1):
        A = Bu[f"A{i}"]
        dfA = pd.DataFrame(A, index=[f"{v}(t-1)" for v in varnames], columns=[f"eq_{v}" for v in varnames])
        print(f"\nBloque A{i}:")
        print(dfA.round(3))
