close @all
' Para que corra desde la ruta donde están los archivos
%path = @runpath
cd %path

' Importa la base desde Excel (ajusta rango cuando agregues filas nuevas)
import "variables_tip_credito_sector1.xlsx" range=Hoja1!$A$3:$AS$211 colhead=1 na="#N/A" @freq M @id @date(t) @smpl @all

' Detalles del workfile y renombra la página principal
	wfdetails Name Display Update Type Description 
	pagerename Variables_tip_credito_sector1 Variables ' Cambio de nombre page

' Interpolación logarítmica para x54 y reemplazo del nombre
	x54.ipolate(type=log) x54ipolate
	delete x54	
	rename x54ipolate x54

' Asigna nombres discretos e intuitivos (sin revelar contenido específico)
c.displayname Const.
resid.displayname Desv. de ajuste
t.displayname Periodo (m)

x11.displayname Segmento A
x12.displayname Segmento B
x13.displayname Segmento C
x14.displayname Uso final
x15.displayname Activo D

x16.displayname Crédito - Total
x17.displayname Cartera - E1
x18.displayname Cartera - E2
x19.displayname Cartera - Activa

x20.displayname Crédito - Moneda 1
x21.displayname Incumplimiento
x22.displayname Tasa de incumpl.
x23.displayname Provisión cartera

x24.displayname Crédito - Moneda 2
x25.displayname Índice de precios
x26.displayname Índice de actividad
x27.displayname Crédito (real)

x28.displayname Crédito/Actividad (%)
x29.displayname Exigencia A
x30.displayname Exigencia B
x31.displayname Tasa P (M1)
x32.displayname Tasa A (M1)

x33.displayname Depósitos T1
x34.displayname Depósitos T2
x35.displayname Depósitos T3

x36.displayname Cartera - E1 (alt)
x37.displayname Cartera - E2 (alt)
x38.displayname Cartera - Activa (alt)
x39.displayname Cartera - Total
x40.displayname Cartera - Mora

x41.displayname Índice TC (real)
x42.displayname Índice externo 1
x43.displayname Índice externo 2

x44.displayname Índice precios (base A)
x45.displayname Crédito (real) v2
x46.displayname Índice precios (base B)
x47.displayname Depósitos (MN)
' Crea tasas de variación interanual (%) para variables seleccionadas
	for %s x16 x20 x21 x25 x26 x47 x28
 	series g_{%s} = ({%s}/{%s}(-12)-1)*100
	g_{%s}.displayname tasa {%s} 
	next

' Carga texto auxiliar con nombres (si existe el archivo)
	text var_name
	var_name.append(file) variables_ces.txt

'*****************************************************************************
'*****************************************************************************


' =======================
' Modelos TAR / TARX / STAR
' =======================

' TAR nominal con 5 umbrales (estimación base)
	equation tar_nominal.threshold g_x16 c @thresh g_x16(-1)

' TAR nominal con búsqueda de 2 quiebres (3 regímenes)
	equation tar_nom.threshold(maxbreaks=2) g_x16 c @thresh g_x16(-1)
	tar_nom.fit(e) g_x16f_nom
	group series01 g_x16 g_x16f_nom
' smpl opcional para acotar muestra
' smpl 2007m01 @last
	freeze(tar_nom_plot) series01.line

' TAR “real” sobre g_x28 (crédito/PIB)
	equation tar_real.threshold g_x28 c @thresh g_x28(-1)

' (STAR comentado en tu código original)
' equation eq01.threshold(size=1) ... 

' TARX (exógenas) con 2 quiebres
	equation tarx_nom.threshold(maxbreaks=2) g_x16 c g_x25 @nv g_x21 g_x21^2 @thresh g_x16(-1)

' Genera tasas para otras exógenas utilizadas en TARX variantes
	for %h x23 x30 x41 x43
		series g_{%h} = ({%h}/{%h}(-12)-1)*100
	next

' TARX ampliado (nominal): incluye tasas y niveles seleccionados
equation tarxa_nom.threshold(maxbreaks=2) g_x16 c g_x25 @nv g_x23 g_x30 x31 x32 g_x43 g_x21 g_x21^2 @thresh g_x16(-1)

' TARXAM sin cuadrática de mora (HAC para var-cov)
equation tarxam_nom.threshold(cov=hac, maxbreaks=2) g_x16 c @nv g_x25 x31 x32 g_x43(-4) g_x21 @thresh g_x16(-1)
tarxam_nom.fit(e) g_x16f_tnom
group series02 g_x16 g_x16f_tnom
freeze(tarxam_nom_plot) series02.line

' Variante: penaliza mora^2 en régimen 2 (lag específico)
equation tarxa_nomi.threshold(cov=hac, maxbreaks=2) g_x16 c @nv g_x25 x31 x32 g_x43(-4) g_x21 g_x21(-3)^2 @thresh g_x16(-1)

' ====== Decoración de gráfico TAR nominal (sombras y etiquetas de regímenes)
tar_nom_plot.setelem(1) linecolor(@rgb(255,0,0))
tar_nom_plot.setelem(2) linecolor(@rgb(0,0,128))
tar_nom_plot.draw(shade, bottom, @rgb(136,136,255)) 2006M02 2007M03
tar_nom_plot.draw(shade, bottom, @rgb(193,193,255)) 2006M02 2007M03
tar_nom_plot.draw(shade, bottom, @rgb(164,164,255)) 2020M02 2021M09
tar_nom_plot.draw(shade, bottom, @rgb(210,210,255)) 2020M02 2021M09
tar_nom_plot.draw(shade, bottom, @rgb(213,213,255)) 2006M02 2007M03
tar_nom_plot.draw(shade, bottom, @rgb(255,255,217)) 2010M04 2020M01
tar_nom_plot.draw(shade, bottom, @rgb(255,255,217)) 2010M04 2017M11
tar_nom_plot.draw(shade, bottom, @rgb(191,191,255)) 2006M02 2007M03
tar_nom_plot.draw(shade, bottom, @rgb(209,209,209)) 2006M02 2007M03
tar_nom_plot.draw(shade, bottom, @rgb(223,223,223)) 2006M02 2007M03
tar_nom_plot.draw(shade, bottom, @rgb(223,223,223)) 2020M02 2021M09
tar_nom_plot.draw(shade, bottom, @rgb(230,230,230)) 2006M02 2007M03
tar_nom_plot.draw(shade, bottom, @rgb(229,229,229)) 2020M02 2021M09
tar_nom_plot.draw(shade, bottom, @rgb(253,230,185)) 2007M03 2010M03
tar_nom_plot.draw(shade, bottom, @rgb(252,220,160)) 2017M12 2020M01
tar_nom_plot.addtext(0.81,0.09, textcolor(@rgb(0,0,0)), fillcolor(@rgb(255,255,255)), framecolor(@rgb(0,0,0)), just(t) , font(Garamond,10,-b,-i,-u,-s))  "Regime 1"
tar_nom_plot.addtext(2.32,0.02, textcolor(@rgb(0,0,0)), fillcolor(@rgb(255,255,255)), framecolor(@rgb(0,0,0)), just(l) , font(Garamond,10,-b,-i,-u,-s))  "Regime 2"
tar_nom_plot.addtext(3.39,0.02, textcolor(@rgb(0,0,0)), fillcolor(@rgb(255,255,255)), framecolor(@rgb(0,0,0)), just(l) , font(Garamond,10,-b,-i,-u,-s))  "Regime 3"
tar_nom_plot.addtext(4.45,0.02, textcolor(@rgb(0,0,0)), fillcolor(@rgb(255,255,255)), framecolor(@rgb(0,0,0)), just(l) , font(Garamond,10,-b,-i,-u,-s))  "Regime 1"
tar_nom_plot.addtext(5.43,0.02, textcolor(@rgb(0,0,0)), fillcolor(@rgb(255,255,255)), framecolor(@rgb(0,0,0)), just(l) , font(Garamond,10,-b,-i,-u,-s))  "Regime 2"

' Decoración de gráfico TARXAM nominal
tarxam_nom_plot.setelem(1) linecolor(@rgb(255,0,0))
tarxam_nom_plot.setelem(2) linecolor(@rgb(0,0,128))
tarxam_nom_plot.draw(shade, bottom, @rgb(136,136,255)) 2006M02 2007M03
tarxam_nom_plot.draw(shade, bottom, @rgb(193,193,255)) 2006M02 2007M03
tarxam_nom_plot.draw(shade, bottom, @rgb(164,164,255)) 2020M02 2021M06
tarxam_nom_plot.draw(shade, bottom, @rgb(210,210,255)) 2020M02 2021M06
tarxam_nom_plot.draw(shade, bottom, @rgb(213,213,255)) 2006M02 2007M03
tarxam_nom_plot.draw(shade, bottom, @rgb(255,255,217)) 2010M04 2020M01
tarxam_nom_plot.draw(shade, bottom, @rgb(255,255,217)) 2010M04 2017M11
tarxam_nom_plot.draw(shade, bottom, @rgb(191,191,255)) 2006M02 2007M03
tarxam_nom_plot.draw(shade, bottom, @rgb(209,209,209)) 2006M02 2007M03
tarxam_nom_plot.draw(shade, bottom, @rgb(223,223,223)) 2006M02 2007M03
tarxam_nom_plot.draw(shade, bottom, @rgb(223,223,223)) 2020M02 2021M06
tarxam_nom_plot.draw(shade, bottom, @rgb(230,230,230)) 2006M02 2007M03
tarxam_nom_plot.draw(shade, bottom, @rgb(229,229,229)) 2020M02 2021M06
tarxam_nom_plot.draw(shade, bottom, @rgb(253,230,185)) 2007M03 2010M03
tarxam_nom_plot.draw(shade, bottom, @rgb(252,220,160)) 2017M12 2020M01
tarxam_nom_plot.addtext(0.81,0.09, textcolor(@rgb(0,0,0)), fillcolor(@rgb(255,255,255)), framecolor(@rgb(0,0,0)), just(t) , font(Garamond,10,-b,-i,-u,-s))  "Regime 1"
tarxam_nom_plot.addtext(2.32,0.02, textcolor(@rgb(0,0,0)), fillcolor(@rgb(255,255,255)), framecolor(@rgb(0,0,0)), just(l) , font(Garamond,10,-b,-i,-u,-s))  "Regime 2"
tarxam_nom_plot.addtext(3.39,0.02, textcolor(@rgb(0,0,0)), fillcolor(@rgb(255,255,255)), framecolor(@rgb(0,0,0)), just(l) , font(Garamond,10,-b,-i,-u,-s))  "Regime 3"
tarxam_nom_plot.addtext(4.45,0.02, textcolor(@rgb(0,0,0)), fillcolor(@rgb(255,255,255)), framecolor(@rgb(0,0,0)), just(l) , font(Garamond,10,-b,-i,-u,-s))  "Regime 1"
tarxam_nom_plot.addtext(5.43,0.02, textcolor(@rgb(0,0,0)), fillcolor(@rgb(255,255,255)), framecolor(@rgb(0,0,0)), just(l) , font(Garamond,10,-b,-i,-u,-s))  "Regime 2"

' Gráfico auxiliar de umbral/regímenes usando residuos (sombreado)
freeze(graph_umbral) tar_nom.resids(g)
graph_umbral.draw(shade, bottom, @rgb(136,136,255)) 2006M02 2007M03
graph_umbral.draw(shade, bottom, @rgb(193,193,255)) 2006M02 2007M03
graph_umbral.draw(shade, bottom, @rgb(164,164,255)) 2020M02 2021M06
graph_umbral.draw(shade, bottom, @rgb(210,210,255)) 2020M02 2021M06
graph_umbral.draw(shade, bottom, @rgb(213,213,255)) 2006M02 2007M03
graph_umbral.draw(shade, bottom, @rgb(255,255,217)) 2010M04 2020M01
graph_umbral.draw(shade, bottom, @rgb(255,255,217)) 2010M04 2017M11
graph_umbral.draw(shade, bottom, @rgb(191,191,255)) 2006M02 2007M03
graph_umbral.draw(shade, bottom, @rgb(209,209,209)) 2006M02 2007M03
graph_umbral.draw(shade, bottom, @rgb(223,223,223)) 2006M02 2007M03
graph_umbral.draw(shade, bottom, @rgb(223,223,223)) 2020M02 2021M06
graph_umbral.draw(shade, bottom, @rgb(230,230,230)) 2006M02 2007M03
graph_umbral.draw(shade, bottom, @rgb(229,229,229)) 2020M02 2021M06
graph_umbral.draw(shade, bottom, @rgb(253,230,185)) 2007M03 2010M03
graph_umbral.draw(shade, bottom, @rgb(252,220,160)) 2017M12 2020M01
graph_umbral.addtext(0.81,0.09, textcolor(@rgb(0,0,0)), fillcolor(@rgb(255,255,255)), framecolor(@rgb(0,0,0)), just(t) , font(Garamond,10,-b,-i,-u,-s))  "Regime 1"
graph_umbral.addtext(2.32,0.02, textcolor(@rgb(0,0,0)), fillcolor(@rgb(255,255,255)), framecolor(@rgb(0,0,0)), just(l) , font(Garamond,10,-b,-i,-u,-s))  "Regime 2"
graph_umbral.addtext(3.39,0.02, textcolor(@rgb(0,0,0)), fillcolor(@rgb(255,255,255)), framecolor(@rgb(0,0,0)), just(l) , font(Garamond,10,-b,-i,-u,-s))  "Regime 3"
graph_umbral.addtext(4.45,0.02, textcolor(@rgb(0,0,0)), fillcolor(@rgb(255,255,255)), framecolor(@rgb(0,0,0)), just(l) , font(Garamond,10,-b,-i,-u,-s))  "Regime 1"
graph_umbral.addtext(5.43,0.02, textcolor(@rgb(0,0,0)), fillcolor(@rgb(255,255,255)), framecolor(@rgb(0,0,0)), just(l) , font(Garamond,10,-b,-i,-u,-s))  "Regime 2"


'===================================================== '
'                 Estimación in-sample                 '
'===================================================== '

' Crea página para modelos logísticos (in-sample) y copia variables
	'pagecreate(page=mod_logexp_in) m 2005M01 2021M09
	'pagecreate(page=mod_logexp_in) m 2005M01 2022M04
	pagecreate(page=mod_logexp_in) m 2005M01 2022M02
	pageselect mod_logexp_in
	for %k x20 x21 x23 x25 x26 x30 x31 x32  x41 x47 x48 x49 x51 x52 x53 x54
		copy Variables\{%k}*
	next

' Tasas de variación anualizadas para subset
	for %k x20 x21 x23 x25 x26 x30 x41 x47 x48 x49 x51 x54
		series g_{%k} =  ({%k}/{%k}(-12)-1)*100
	next

' Semilla para reproducibilidad
	rndseed 1234567890

' Refresca detalles de nombres
	wfdetails Name Display Update Type 

' Etiquetas legibles para gráficos/tablas
	g_x20.displayname Var Credito total 
	g_x21.displayname Var. Cartera en mora
	g_x23.displayname Var. prevision para incobrabilidad de cartera 
	g_x25.displayname Inflación
	g_x26.displayname Var. Producto Interno Bruto
	g_x30.displayname Var. encaje constituido
	x31.displayname Tasa pasiva efectiva MN
	x32.displayname Tasa activa efectiva MN
	g_x41.displayname Var. tipo de cambio real
	g_x47.displayname Var. depósitos 
	g_x48.displayname Var. RIN 
	g_x49.displayname Var. CIN 
	g_x51.displayname Var. OMAs
	x52.displayname Tasa de rendimiento Letes 91 días
	x53.displayname Bolivianización depósitos
	g_x54.displayname Var. Liquidez

' Construye brechas de PIB (HP lambda estándar y alterno)
	x26.x12
	x26_sa.hpf pib_trend
	x26_sa.hpf(lambda=1000) pib_hp1000
	series brecha = ((x26_sa-pib_trend)/pib_trend)*100
	brecha.displayname Brecha del PIB
	series brecha1 = ((x26_sa-pib_hp1000)/pib_hp1000)*100
	brecha1.displayname Brecha del PIBBB

' Submuestra para modelos de liquidez y variantes TARX
	smpl 2010m01 2022m02
	equation tar_ttt.threshold(maxbreaks=2) g_x54 c x32 x31 g_x51 x52 g_x47 g_x20 brecha @nv g_x21 g_x21^2 x53 @thresh g_x26(-1)
	equation tar_tttt.threshold(maxbreaks=3) g_x54 c x32 x52 g_x47 g_x20 g_x54(-1) @nv g_x21 x53 g_x51 @thresh g_x26(-1)
	equation tar_ttttt.threshold(maxbreaks=2) g_x54 c x32 x52 g_x47 g_x20 @nv g_x21 x53 g_x51 @thresh g_x26(-1)
	smpl @all

' TARX sobre crédito total (distintas especificaciones)
	equation tar_x.threshold(cov=hac, maxbreaks=2) g_x20 c x21 x21^2 g_x25 g_x26 g_x30 x31 x32 g_x41 @thresh g_x20(-1)
	equation tar_x1.threshold(maxbreaks=2) g_x20 c x21 x21^2 g_x26 g_x30 x31 x32 g_x41 g_x25 @thresh g_x20(-1)
	equation tar_y.threshold(maxbreaks=2) g_x20 c x21 x21^2 g_x30 x31 x32 g_x25(-6) @nv g_x26 @thresh g_x20(-1)
	equation tar_z.threshold(maxbreaks=2) g_x20 c x21 x21^2 g_x30 x32 g_x25(-6) @nv g_x26 x31 @thresh g_x20(-1)
	equation tar_zz.threshold(maxbreaks=2) g_x20 c g_x21 g_x21^2 g_x30 x32 g_x25(-6) @nv g_x26 x31 @thresh g_x20(-1)
	equation tar_zzz.threshold(cov=hac, maxbreaks=2) g_x20 c g_x21 g_x21^2 g_x25(-6) g_x26(-3) @nv x31 g_x20(-1) x32(-1) @thresh g_x20(-1)
	' equation tar_zzzz.threshold(...) con dummies de fechas (comentado)

' Modelo preferido (TARX) y pronóstico in-sample
	equation tar_zzzzz.threshold(cov=hac, maxbreaks=2) g_x20 c g_x21 g_x25(-6) g_x26(-3) @nv x31 g_x20(-1) g_x21^2 x32(-7) @isperiod("2020m04") @thresh g_x20(-1)	
	tar_zzzzz.fit(e) g_x20fz
	g_x20fz.displayname Regímenes var. créditos
	group series02 g_x20fz g_x20
	freeze(plot_cred_z) series02.line

' Formato de gráfico de crédito y sombreado por regiones (umbral manual)
	plot_cred_z.axis(l) mintickcount(5)
	plot_cred_z.legend columns(2)
	plot_cred_z.setelem(1) linecolor(@rgb(255,0,0))
	plot_cred_z.setelem(2) linecolor(@rgb(0,0,128))
	plot_cred_z.draw(shade, bottom, @rgb(216,222,222))  if g_x20<9.008718 
	plot_cred_z.draw(shade, bottom, @rgb(255,255,217))  if g_x20>9.008718 and g_x20<12.63518
	plot_cred_z.draw(shade, bottom, @rgb(151,255,255))  if g_x20>12.63518
	plot_cred_z.draw(line, left, @rgb(0,0,0), pattern(7), linewidth(1))  12.63518
	plot_cred_z.draw(line, left, @rgb(0,0,0), pattern(7), linewidth(1))  9.008718
	plot_cred_z.addtext(0.05, 2.12, textcolor(@rgb(0,0,0)), fillcolor(@rgb(255,255,255)), framecolor(@rgb(0,0,0)), just(l) , font(Garamond,8,-b,-i,-u,-s))  "Threshold 1: 9"
	plot_cred_z.addtext(0.05, 1.42, textcolor(@rgb(0,0,0)), fillcolor(@rgb(255,255,255)), framecolor(@rgb(0,0,0)), just(l) , font(Garamond,8,-b,-i,-u,-s))  "Threshold 2: 12,3"	
	plot_cred_z.addtext(0.33,0.07, textcolor(@rgb(0,0,0)), fillcolor(@rgb(255,255,255)), framecolor(@rgb(0,0,0)), just(t) , font(Garamond,10,-b,-i,-u,-s))  "Regime 1"
	plot_cred_z.addtext(1.16,0.07, textcolor(@rgb(0,0,0)), fillcolor(@rgb(255,255,255)), framecolor(@rgb(0,0,0)), just(l) , font(Garamond,10,-b,-i,-u,-s))  "Regime 2"
	plot_cred_z.addtext(3.09,0.07, textcolor(@rgb(0,0,0)), fillcolor(@rgb(255,255,255)), framecolor(@rgb(0,0,0)), just(l) , font(Garamond,10,-b,-i,-u,-s))  "Regime 3"
	plot_cred_z.addtext(4.83,0.07, textcolor(@rgb(0,0,0)), fillcolor(@rgb(255,255,255)), framecolor(@rgb(0,0,0)), just(l) , font(Garamond,10,-b,-i,-u,-s))  "Regime 2"
	plot_cred_z.addtext(5.42,0.07, textcolor(@rgb(0,0,0)), fillcolor(@rgb(255,255,255)), framecolor(@rgb(0,0,0)), just(l) , font(Garamond,10,-b,-i,-u,-s))  "Regime 1"

' Actualización alternativa del modelo (especificación distinta)
	equation tar_wwwww.threshold(cov=hac, maxbreaks=2) g_x20 c g_x21 g_x25(-6) g_x26(-3) @nv x31 g_x20(-1) g_x21^2 x32(-7) @isperiod("2020m04") @thresh g_x20
	tar_wwwww.fit(e) g_x20fx
	g_x20fx.displayname Regímenes var. créditos
	group series02x g_x20fx g_x20
	freeze(plot_cred_x) series02x.line

' *** Actualización a diciembre (otra especificación candidata)
equation tar_www.threshold(maxbreaks=2) g_x20 c x21 x21^2 x32 @nv g_x26(-5) x31 @thresh g_x20(-1)
	tar_www.fit(e) g_x20fw
	g_x20fw.displayname Regímenes var. créditos
	group series_www g_x20fw g_x20
	freeze(plot_cred_w) series_www.line
equation tar_sss.threshold(maxbreaks=2) g_x20 c x21 x21^2 x32 @nv g_x26(-5) x31 @thresh g_x26(-1)


' ============================
' Modelos de transición suave
' ============================

' LSTAR (logístico) con distintas combinaciones
	equation stl_01.threshold(type=smooth) g_x20 g_x21 g_x23 g_x25 g_x26 x31 x32 c @nv g_x30 @thresh brecha
	equation stl_02.threshold(type=smooth, optmethod=newton, maxit=100000, cov=white) g_x20 g_x23 g_x25 x31 x32 c g_x21 g_x21^2 @nv g_x30 @thresh brecha
	equation stl_03.threshold(type=smooth, optmethod=newton, maxit=100000, cov=white) g_x20 g_x23 g_x25 x31 x32 c g_x21 g_x21^2 @nv g_x30 g_x26(-3) @thresh brecha
	equation stl_04.threshold(type=smooth, optmethod=newton, maxit=100000, cov=white) g_x20 g_x23 g_x25 x31 c x32 @nv g_x30 g_x26 g_x21(-6) g_x21^2 @thresh brecha

' Pesos suaves (para graficar la transición logística)
	equation stl_05.threshold(type=smooth, optmethod=newton, maxit=100000, cov=white) g_x20 g_x23 g_x25 x31 c x32(-3) @nv g_x30 g_x26 g_x21(-6) g_x21^2 @thresh brecha
	freeze(Logistico) stl_05.strwgts
	stl_05.displayname logisitic regression

' LSTAR alterno para gráfico del modelo
equation stl_06.threshold(type=smooth, optmethod=newton, maxit=100000, cov=white) g_x20 g_x23 g_x25 x31 x32(-3) @nv g_x30 g_x26 g_x21(-6) g_x21^2 @thresh brecha

' Variante LSTAR con otro conjunto de exógenas
equation stl_06estrellita.threshold(type=smooth, optmethod=newton, maxit=100000, cov=white) g_x20 g_x23 x31 x32(-3) @nv g_x30 g_x21(-6) g_x25 g_x47 @thresh g_x26(-3)

' ESTAR (exponencial) con distintas combinaciones
	equation ste_01.threshold(type=smooth, optmethod=newton, maxit=100000, cov=white, smoothtrans=exponential) g_x20 g_x23 c x32 @nv g_x30 g_x26 g_x25 x31 @thresh brecha
	equation ste_01estrella.threshold(type=smooth, optmethod=newton, optstep=linesearch, maxit=100000, cov=white, smoothtrans=exponential) g_x20 g_x23 c x32 @nv g_x30 g_x25 x31 g_x26 @thresh brecha
	freeze(exponencial) ste_01.strwgts
	ste_01.displayname exponential regression

' Grupo para exportar insumos (si deseas exportar luego)
group series_export G_X20 G_X23	G_X25 X31	X32 G_X21 G_X30 G_X26

' ESTAR alterno con retardo distinto de umbral
equation ste_01estrellita.threshold(type=smooth, optmethod=newton, optstep=linesearch, maxit=100000, cov=white, smoothtrans=exponential) g_x20 g_x23 c x32 @nv g_x30 g_x25 x31 @thresh g_x26(-5)

