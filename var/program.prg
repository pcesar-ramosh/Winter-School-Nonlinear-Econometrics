close @all
cd "D:\Paulo Ramos\Nueva carpeta (2)\GitHub\Winter-School-Nonlinear-Econometrics\var"
import "dataset.xlsx" range=Hoja1 colhead=1 na="#N/A" @freq M @id @date(time) @smpl @all

delete time

'==================='
' Otra hoja "Dataset en Niveles"
'==================='

'Seasonal Adjustment
igae.x12

'Raiz Unitaria
freeze(tabla_uroot1) igae.uroot
freeze(tabla_uroot2) igae.uroot(exog=trend,dif=1)
freeze(tabla_uroot3) igae.uroot(exog=trend,dif=2)

' Grafico Lineal
series d1_igae = d(igae_sa, 1)
series d2_igae = d(igae_sa, 2)

group series_diff d1_igae d2_igae
freeze(diferencias) series_diff.line

'==================='
' Otra hoja "tasas"
'==================='
pagecreate(page=tasas) m 1990M01 2025M07
for %i ALI DIV IGAE IM IPC ITCR M2 NOALI WTI XP 
	copy Dataset\{%i} *
next

for %g ALI DIV IGAE IM IPC ITCR M2 NOALI WTI XP 
	series g_{%g} = ({%g}/{%g}(-12)-1)*100 ' Tasa Anualizada
	delete {%g} 
next

' Estadisticos
group series01 g_*
freeze(tabla_stats) series01.stats(i)
' Analisis de Correlacion
freeze(tabla_corr) series01.cov(outfmt=sheet) corr

' Test de Raiz Unitaria
freeze(tabla01) g_igae.uroot
freeze(tabla02) g_igae.uroot(pp)
freeze(tabla03) g_igae.uroot(exog=trend, np, maxlag=10)
freeze(tabla04) g_igae.buroot

'==================='
' Modelo VAR
'==================='
pagecreate(page=var) m 1990M01 2025M07
for %j g_ALI g_DIV g_IGAE g_IM g_IPC g_ITCR g_M2 g_NOALI g_WTI g_XP 
	copy tasas\{%j} *
next

' Estimacion de un modelo VAR con tasas anualizadas
var var01.ls 1 2 g_igae g_ipc g_wti

freeze(lag_criteria) var01.laglen(8)

freeze(raices) var01.arroots
freeze(cic_unit) var01.arroots(graph)

' Residiual correlation LM
freeze(correlograma) var01.arlm(3)

' Test Normalidad
freeze(Normalidad) var01.jbera

' IRF
freeze(fir) var01.impulse(se=a)

' Cumulated IRF
freeze(cumirf) var01.impulse(a, se=a)

' Predict 
pagestruct(start=1992M01)
var var01.ls 1 2 g_igae g_ipc g_wti
var01.fit(g, e, n, fangraph, median, unstable) f

'Descomposición Histórica
freeze(descomp) var01.hdecomp g_igae

' Descomposición de varianza
freeze(desc_varianza) var01.decomp(m) g_igae

