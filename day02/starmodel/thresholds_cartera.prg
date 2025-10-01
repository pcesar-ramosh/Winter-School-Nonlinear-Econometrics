close @all
' Para que corra desde la ruta donde están los archivos
%path = @runpath
cd %path
' Actualizar el rango de la hoja excel al añadir más observaciones ***
import "variables_tip_credito_sector1.xlsx" range=Hoja1!$A$3:$AS$211 colhead=1 na="#N/A" @freq M @id @date(t) @smpl @all
' Detalles del workfile
	wfdetails Name Display Update Type Description 
	pagerename Variables_tip_credito_sector1 Variables ' Cambio de nombre page

' Data filling
	x54.ipolate(type=log) x54ipolate
	delete x54	
	rename x54ipolate x54
' Nombre de las variables y etiquetas
	c.displayname constante
	resid.displayname residuos del modelo
	t.displayname tiempo mes
	x11.displayname Empresarial
	x12.displayname Microcredito
	x13.displayname Pyme
	x14.displayname Consumo
	x15.displayname Vivienda
	x16.displayname Crédito total
	x17.displayname Cartera ejecución
	x18.displayname Cartera vencida
	x19.displayname Cartera vigente
	x20.displayname Crédito total en bolivianos
	x21.displayname Cartera en mora
	x22.displayname Ratio mora
	x23.displayname Prevision para incobrabilidad de cartera 
	x24.displayname Crédito total dólares
	x25.displayname Índice de precios al consumidor
	x26.displayname Producto Interno Bruto
	x27.displayname Crédito real
	x28.displayname Crédito como % PIB
	x29.displayname Encaje requerido
	x30.displayname Encaje constituido
	x31.displayname Tasa pasiva efectiva MN
	x32.displayname Tasa activa efectiva MN
	x33.displayname Depósitos a la vista
	x34.displayname Depósitos cajas de ahorro
	x35.displayname Depósitos a plazo fijo
	x36.displayname Cartera Ejecución
	x37.displayname Cartera Vencida
	x38.displayname Cartera Vigente
	x39.displayname Total Cartera de créditos
	x40.displayname Cartera Mora
	x41.displayname Tipo de cambio real
	x42.displayname GEPU current
	x43.displayname GEPU ppp
	x44.displayname ipc1990
	x45.displayname credito real
	x46.displayname ipc2016 
	x47.displayname Depósitos (en millones de bs)

' Variables en tasas para el Modelo
	for %s x16 x20 x21 x25 x26 x47 x28
 	series g_{%s} = ({%s}/{%s}(-12)-1)*100
	g_{%s}.displayname tasa {%s} 
	next
' Texto de las variables
	text var_name
	var_name.append(file) variables_ces.txt

'*****************************************************************************
'*****************************************************************************

' Modelo TAR
	' Con 5 umbrales y 6 regiones (nominal)
	equation tar_nominal.threshold g_x16 c @thresh g_x16(-1)
	' Con 2 umbrales y 3 regiones
	equation tar_nom.threshold(maxbreaks=2) g_x16 c @thresh g_x16(-1)
	tar_nom.fit(e) g_x16f_nom
	group series01 g_x16 g_x16f_nom
'smpl 2007m01 @last
	freeze(tar_nom_plot) series01.line
	' Con 5 umbrales y 6 regiones (real)
	equation tar_real.threshold g_x28 c @thresh g_x28(-1)

' Modelo STAR
	'equation eq01.threshold(size=1) g_x16 c @nv @isperiod("2019m11") @isperiod("2011m07") @thresh g_x16(-1)
	' Modelo TARX
	equation tarx_nom.threshold(maxbreaks=2) g_x16 c g_x25 @nv g_x21 g_x21^2 @thresh g_x16(-1)

	for %h x23 x30 x41 x43
		series g_{%h} = ({%h}/{%h}(-12)-1)*100
	next
 
equation tarxa_nom.threshold(maxbreaks=2) g_x16 c g_x25 @nv g_x23 g_x30 x31 x32 g_x43 g_x21 g_x21^2 @thresh g_x16(-1)
' sin coeficiente al cuadrado de la mora
equation tarxam_nom.threshold(cov=hac, maxbreaks=2) g_x16 c @nv g_x25 x31 x32 g_x43(-4) g_x21 @thresh g_x16(-1)
tarxam_nom.fit(e) g_x16f_tnom
group series02 g_x16 g_x16f_tnom
freeze(tarxam_nom_plot) series02.line

' Castiga la mora al cuadrado a la tasa del regimen 2
equation tarxa_nomi.threshold(cov=hac, maxbreaks=2) g_x16 c @nv g_x25 x31 x32 g_x43(-4) g_x21 g_x21(-3)^2 @thresh g_x16(-1)


' Gráfico del modelo TAR nominal distinguiendo regímenes (tar_nom_plot)
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


' Gráfico del modelo TARXAM nominal distinguiendo regímenes (tarxam_nom_plot)
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



' Gráfico de las regiones
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


'====================================================='
'====================================================='
'====================================================='

' ============='
' Estimación in sample '
' ============='

' ##########################'
' ##########################'
' Regresión logística
' ##########################'
' ##########################'
	'pagecreate(page=mod_logexp_in) m 2005M01 2021M09
	'pagecreate(page=mod_logexp_in) m 2005M01 2022M04
	pagecreate(page=mod_logexp_in) m 2005M01 2022M02
	pageselect mod_logexp_in
	' Copiamos las variables que requerimos
	for %k x20 x21 x23 x25 x26 x30 x31 x32  x41 x47 x48 x49 x51 x52 x53 x54
		copy Variables\{%k}*
	next
	' En tasas de variación anualizadas
	for %k x20 x21 x23 x25 x26 x30 x41 x47 x48 x49 x51 x54
		series g_{%k} =  ({%k}/{%k}(-12)-1)*100
	next
	rndseed 1234567890
' Nombres y detalle de las variables	
	wfdetails Name Display Update Type 
' Etiquetas de las variables
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
' Brecha del producto
	x26.x12
	x26_sa.hpf pib_trend
	x26_sa.hpf(lambda=1000) pib_hp1000
	series brecha = ((x26_sa-pib_trend)/pib_trend)*100
	brecha.displayname Brecha del PIB
	series brecha1 = ((x26_sa-pib_hp1000)/pib_hp1000)*100
	brecha1.displayname Brecha del PIBBB
' Para el caos de la liquidez
	smpl 2010m01 2022m02
	equation tar_ttt.threshold(maxbreaks=2) g_x54 c x32 x31 g_x51 x52 g_x47 g_x20 brecha @nv g_x21 g_x21^2 x53 @thresh g_x26(-1)
	equation tar_tttt.threshold(maxbreaks=3) g_x54 c x32 x52 g_x47 g_x20 g_x54(-1) @nv g_x21 x53 g_x51 @thresh g_x26(-1)
	equation tar_ttttt.threshold(maxbreaks=2) g_x54 c x32 x52 g_x47 g_x20 @nv g_x21 x53 g_x51 @thresh g_x26(-1)
	smpl @all
' Estimación del modelo con variables exógenas
	equation tar_x.threshold(cov=hac, maxbreaks=2) g_x20 c x21 x21^2 g_x25 g_x26 g_x30 x31 x32 g_x41 @thresh g_x20(-1)
	equation tar_x1.threshold(maxbreaks=2) g_x20 c x21 x21^2 g_x26 g_x30 x31 x32 g_x41 g_x25 @thresh g_x20(-1)
	equation tar_y.threshold(maxbreaks=2) g_x20 c x21 x21^2 g_x30 x31 x32 g_x25(-6) @nv g_x26 @thresh g_x20(-1)

	equation tar_z.threshold(maxbreaks=2) g_x20 c x21 x21^2 g_x30 x32 g_x25(-6) @nv g_x26 x31 @thresh g_x20(-1)
	equation tar_zz.threshold(maxbreaks=2) g_x20 c g_x21 g_x21^2 g_x30 x32 g_x25(-6) @nv g_x26 x31 @thresh g_x20(-1)
	equation tar_zzz.threshold(cov=hac, maxbreaks=2) g_x20 c g_x21 g_x21^2 g_x25(-6) g_x26(-3) @nv x31 g_x20(-1) x32(-1) @thresh g_x20(-1)
	
	'equation tar_zzzz.threshold(cov=hac, maxbreaks=2) g_x20 c g_x21 g_x21^2 g_x25(-6) g_x26(-3) @nv x31 g_x20(-1) x32(-1) @isperiod("2020m04") @isperiod("2019m12") @isperiod("2021m05") @thresh g_x20(-1)
' Modelo que mejor se ajusta - Umbral discreto - y Autoespecificado
	equation tar_zzzzz.threshold(cov=hac, maxbreaks=2) g_x20 c g_x21 g_x25(-6) g_x26(-3) @nv x31 g_x20(-1) g_x21^2 x32(-7) @isperiod("2020m04") @thresh g_x20(-1)	
	tar_zzzzz.fit(e) g_x20fz
	g_x20fz.displayname Regímenes var. créditos
	group series02 g_x20fz g_x20
	freeze(plot_cred_z) series02.line

' Con varias exógenas "plot_cred_z"
	' Ticks para el eje izquierdo
	plot_cred_z.axis(l) mintickcount(5)
	' Etiquetas en dos columnas
	plot_cred_z.legend columns(2)
	' Color de cada línea
	plot_cred_z.setelem(1) linecolor(@rgb(255,0,0))
	plot_cred_z.setelem(2) linecolor(@rgb(0,0,128))
	' Sombras en cada área - para las regiones
	' Para datos menores a 9.008718 que es la Región 1 BAJA
	plot_cred_z.draw(shade, bottom, @rgb(216,222,222))  if g_x20<9.008718 
	'  Para datos entre 9.008718 y 12.63518 que es la Región 2 MEDIA
	plot_cred_z.draw(shade, bottom, @rgb(255,255,217))  if g_x20>9.008718 and g_x20<12.63518
	'  Para datos mayores a 12.63518 que es la Región 3 ALTA
	plot_cred_z.draw(shade, bottom, @rgb(151,255,255))  if g_x20>12.63518
	' Graficamos dos lines horizontales  (Umbrales)
	plot_cred_z.draw(line, left, @rgb(0,0,0), pattern(7), linewidth(1))  12.63518
	plot_cred_z.draw(line, left, @rgb(0,0,0), pattern(7), linewidth(1))  9.008718
	plot_cred_z.addtext(0.05, 2.12, textcolor(@rgb(0,0,0)), fillcolor(@rgb(255,255,255)), framecolor(@rgb(0,0,0)), just(l) , font(Garamond,8,-b,-i,-u,-s))  "Threshold 1: 9"
	plot_cred_z.addtext(0.05, 1.42, textcolor(@rgb(0,0,0)), fillcolor(@rgb(255,255,255)), framecolor(@rgb(0,0,0)), just(l) , font(Garamond,8,-b,-i,-u,-s))  "Threshold 2: 12,3"	
	' Etiquetas para cada region, Regímenes  R-1, R-2 y R-3
	plot_cred_z.addtext(0.33,0.07, textcolor(@rgb(0,0,0)), fillcolor(@rgb(255,255,255)), framecolor(@rgb(0,0,0)), just(t) , font(Garamond,10,-b,-i,-u,-s))  "Regime 1"
	plot_cred_z.addtext(1.16,0.07, textcolor(@rgb(0,0,0)), fillcolor(@rgb(255,255,255)), framecolor(@rgb(0,0,0)), just(l) , font(Garamond,10,-b,-i,-u,-s))  "Regime 2"
	plot_cred_z.addtext(3.09,0.07, textcolor(@rgb(0,0,0)), fillcolor(@rgb(255,255,255)), framecolor(@rgb(0,0,0)), just(l) , font(Garamond,10,-b,-i,-u,-s))  "Regime 3"
	plot_cred_z.addtext(4.83,0.07, textcolor(@rgb(0,0,0)), fillcolor(@rgb(255,255,255)), framecolor(@rgb(0,0,0)), just(l) , font(Garamond,10,-b,-i,-u,-s))  "Regime 2"
	plot_cred_z.addtext(5.42,0.07, textcolor(@rgb(0,0,0)), fillcolor(@rgb(255,255,255)), framecolor(@rgb(0,0,0)), just(l) , font(Garamond,10,-b,-i,-u,-s))  "Regime 1"

	'  Modelo actualizado a septiembre de 2020 ---- Actualización del modelo al 8 de febrero de 2022
	equation tar_wwwww.threshold(cov=hac, maxbreaks=2) g_x20 c g_x21 g_x25(-6) g_x26(-3) @nv x31 g_x20(-1) g_x21^2 x32(-7) @isperiod("2020m04") @thresh g_x20
	tar_wwwww.fit(e) g_x20fx
	g_x20fx.displayname Regímenes var. créditos
	group series02x g_x20fx g_x20
	freeze(plot_cred_x) series02x.line

'******************************************'
'******************************************'
' *** Actualización *** este modelo a diciembre
' Modelo que mejor se ajusta - Umbral discreto - y Autoespecificado
equation tar_www.threshold(maxbreaks=2) g_x20 c x21 x21^2 x32 @nv g_x26(-5) x31 @thresh g_x20(-1)
	tar_www.fit(e) g_x20fw
	g_x20fw.displayname Regímenes var. créditos
	group series_www g_x20fw g_x20
	freeze(plot_cred_w) series_www.line
equation tar_sss.threshold(maxbreaks=2) g_x20 c x21 x21^2 x32 @nv g_x26(-5) x31 @thresh g_x26(-1)


'%%%%%%%%%%%%%%%%%%%%%%
'___Modelo de transición suave Logístico___'
'%%%%%%%%%%%%%%%%%%%%%%
	equation stl_01.threshold(type=smooth) g_x20 g_x21 g_x23 g_x25 g_x26 x31 x32 c @nv g_x30 @thresh brecha
	equation stl_02.threshold(type=smooth, optmethod=newton, maxit=100000, cov=white) g_x20 g_x23 g_x25 x31 x32 c g_x21 g_x21^2 @nv g_x30 @thresh brecha
	equation stl_03.threshold(type=smooth, optmethod=newton, maxit=100000, cov=white) g_x20 g_x23 g_x25 x31 x32 c g_x21 g_x21^2 @nv g_x30 g_x26(-3) @thresh brecha
	equation stl_04.threshold(type=smooth, optmethod=newton, maxit=100000, cov=white) g_x20 g_x23 g_x25 x31 c x32 @nv g_x30 g_x26 g_x21(-6) g_x21^2 @thresh brecha

' Para el gráfico logístico

	equation stl_05.threshold(type=smooth, optmethod=newton, maxit=100000, cov=white) g_x20 g_x23 g_x25 x31 c x32(-3) @nv g_x30 g_x26 g_x21(-6) g_x21^2 @thresh brecha
	freeze(Logistico) stl_05.strwgts
	stl_05.displayname logisitic regression

' Pra el gráfico del modelo logístico
equation stl_06.threshold(type=smooth, optmethod=newton, maxit=100000, cov=white) g_x20 g_x23 g_x25 x31 x32(-3) @nv g_x30 g_x26 g_x21(-6) g_x21^2 @thresh brecha

equation stl_06estrellita.threshold(type=smooth, optmethod=newton, maxit=100000, cov=white) g_x20 g_x23 x31 x32(-3) @nv g_x30 g_x21(-6) g_x25 g_x47 @thresh g_x26(-3)
'%%%%%%%%%%%%%%%%%%%%%%
'__Modelo de transición suave exponencial__'
'%%%%%%%%%%%%%%%%%%%%%%
' Modelo exponencial
	equation ste_01.threshold(type=smooth, optmethod=newton, maxit=100000, cov=white, smoothtrans=exponential) g_x20 g_x23 c x32 @nv g_x30 g_x26 g_x25 x31 @thresh brecha
	equation ste_01estrella.threshold(type=smooth, optmethod=newton, optstep=linesearch, maxit=100000, cov=white, smoothtrans=exponential) g_x20 g_x23 c x32 @nv g_x30 g_x25 x31 g_x26 @thresh brecha
	freeze(exponencial) ste_01.strwgts
	ste_01.displayname exponential regression
' Exportaci´ón de los datos
group series_export G_X20 G_X23	G_X25 X31	X32 G_X21 G_X30 G_X26

equation ste_01estrellita.threshold(type=smooth, optmethod=newton, optstep=linesearch, maxit=100000, cov=white, smoothtrans=exponential) g_x20 g_x23 c x32 @nv g_x30 g_x25 x31 @thresh g_x26(-5)


