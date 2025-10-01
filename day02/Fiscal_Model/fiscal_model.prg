' ==============================================================
'  Modelo de Umbrales (TAR) – Winter School: Econometría No Lineal
' ==============================================================

close @all
cd "C:\Users\CESAR\Documents\GitHub\Winter-School-Nonlinear-Econometrics\day02\Fiscal_Model"
wfopen "modelo_fiscal.wf1"
smpl @all

'-------------------------------
' 1) Gráfico preliminar de series
'-------------------------------
group series_plots crecimiento c_tcr demanda_interna exportaciones inflacion resultado_fiscal tasa_activa360 apertura_comercial dummy1
series_plots.line(m)
show series_plots

'===============================================================
' 2) ESTIMACIONES TAR
'===============================================================

' (A) TAR discreto con umbral ESPECIFICADO (t = -8)
equation modelo_2005_2022.threshold(method=user, breaks=-8) crecimiento resultado_fiscal(-4) @nv dummy1 tasa_activa360 demanda_interna exportaciones(-1) crecimiento(-1) crecimiento(-2) c @thresh resultado_fiscal
show modelo_2005_2022

' (B) TAR con BÚSQUEDA SECUENCIAL (Bai–Perron L+1 vs L)
equation modelo_base01.threshold crecimiento resultado_fiscal(-4) @nv dummy1 tasa_activa360 demanda_interna exportaciones(-2) crecimiento(-1) crecimiento(-2) crecimiento(-12) c @thresh resultado_fiscal
show modelo_base01

' (C) Variante con inflación y umbral FIJO en t = -8.568232
equation modelo_con_inflacion.threshold(method=user, breaks=-8.568232) crecimiento resultado_fiscal(-4) @nv dummy1 inflacion(-2) tasa_activa360 demanda_interna c_tcr crecimiento(-1) crecimiento(-2) crecimiento(-12) c @thresh resultado_fiscal
show modelo_con_inflacion

'===============================================================
' 3) GRAFICAR UMBRAL Y REGÍMENES  (usando t del test secuencial)
'===============================================================
scalar tau_base01 = -8.568232

series reg1 = (resultado_fiscal <= tau_base01)
series reg2 = 1 - reg1

series rf_reg1  = @recode(reg1=1, resultado_fiscal, NA)
series rf_reg2  = @recode(reg2=1, resultado_fiscal, NA)
series cre_reg1 = @recode(reg1=1, crecimiento,      NA)
series cre_reg2 = @recode(reg2=1, crecimiento,      NA)

series tau_line = tau_base01

' --- (3.1) Gráfico temporal de la variable de umbral con la línea t ---
delete(noerr) g_umbral
graph g_umbral.line rf_reg1 rf_reg2 tau_line
g_umbral.setelem(1) lcolor(blue) lwidth(1)
g_umbral.setelem(2) lcolor(red)  lwidth(1)
g_umbral.setelem(3) lcolor(gray) lwidth(2)
g_umbral.addtext(t) "Umbral  = 8.568232 " 
show g_umbral

' --- (3.2)  CRECIMIENTO vs RESULTADO_FISCAL por regímenes ---
delete(noerr) g_scatter
graph g_scatter.line cre_reg1 rf_reg1 cre_reg2 rf_reg2
'g_scatter.setelem(1) symbol(circle) scolor(blue)
'g_scatter.setelem(2) symbol(circle) scolor(red)
g_scatter.addtext(t) "Crecimiento vs Resultado Fiscal (por régimen)"
show g_scatter

' (3.3) Conteo de observaciones por régimen
scalar n1 = @sum(reg1)
scalar n2 = @sum(reg2)
show n1 n2

'===============================================================
' 4) NOTAS 
' - Bai–Perron 0 vs 1: si F > crítico, hay no linealidad (1 umbral).
' - 1 vs 2: si no es sig., quedarse con 1 umbral (2 regímenes).
' - “Threshold varying”: regresores con coeficientes que cambian por régimen.
' - “Non-varying”: coeficientes comunes a todos los regímenes.
'===============================================================


