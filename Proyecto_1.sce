clear
////////////////////////////////////////
// Encuantra_Regresiones_1.sce
// El programa lee de un archivo de excel, cuyo nombre es dado ppor el usuario
// Calcula funciones de regrion lineal, de cuadrática, de potencia, y
// exponencial. Despliega cada una de estas funciones a la consola, además de 
// desplegar una gráfica con cada una de estas regresiones. Finalmente,
// escribe un archivo con los resultados utilizando la mejor regresión
// David García - A01570231
// Kevin Chinchilla - A00825945
// 27/11/2019 v 1.0
////////////////////////////////////////

////////////////////////////////////////
// getFile
// pide al usuario el nombre un archivo xls y obtiene las primeras dos columnas
// de la primera hoja de dicho archivo
// Retorno
// 	dArrx: Un vector con los valores de la primea columna
// 	dArrY: Un vector con los valores de la segunda columna
////////////////////////////////////////
function [dArrX, dArrY] = getFile()
    sFileName = input("¿Cuál es el nombre del archivo .xls? ", "string")
    if grep(sFileName, '/.*\.xls$/', 'r') == []  then
        sFileName = sFileName + '.xls'
    end

    dSheet = readxls(sFileName)
    dSheet = dSheet(1)
    dArrX=dSheet(:,1)
    dArrY=dSheet(:,2)
endfunction

////////////////////////////////////////
// gaussJordan
// Resuelve una matriz por el metodo de Gauss-Jordan
// Parametros:
// 	dMat: Una matriz de double
// Retorno:
//	dMat: Una matriz resuelta de double
////////////////////////////////////////
function dMat = gaussJordan(dMat)
    fact = 0
    for iRowIndex = 1 : size(dMat, 1)
        dPivote = dMat(iRowIndex, iRowIndex)

        for iColIndex = 1 : size(dMat, 2)
            dMat(iRowIndex, iColIndex) = dMat(iRowIndex, iColIndex)/dPivote
        end
        for iRowK = 1 : size(dMat, 1)
            if iRowK <> iRowIndex then
                fact = -dMat(iRowK, iRowIndex)

                for iColJ = 1 : size(dMat,2)
                    dMat(iRowK, iColJ) = dMat(iRowK, iColJ) + fact * dMat(iRowIndex, iColJ)
                end
            end
        end
    end
endfunction

////////////////////////////////////////
// sumaDiag
// Suma la diagonal principal de una matriz
// Parametros:
// 	dMat: Una matriz con valores double
// Retorno
// 	dSum: el resultado de la suma de la diagonal principal
////////////////////////////////////////
function dSum = sumaDiag(dMat)
    dSum = 0
    for iIndex = 1 : size(dMat,1)
        dSum = dMat(iIndex, iIndex) + dSum
    end
endfunction

////////////////////////////////////////
// dGetR
// Obtiene la funcion y consigue los datos correspondientes para el display
// Parametros:
// 	rLin: valor de la R cuadrada de la función lineal
// 	rCuad: valor de la R cuadrada de la función cuadrática
// 	rExp: valor de la R cuadrada de la función exponencial
// 	rPot: valor de la R cuadrada de la función potencial
// Retorno:
// 	dBestR: Representa el valor R cuadrada más grande de las funciones de regresión
// 	sBest: Representa una palabra que describe la función con mejor R cuadrada
// 	funWin: Toma la función de la regresion con mejor R cuadrada
////////////////////////////////////////
function [dBestR,sBest, funWin] = dGetR(rLin, rCuad, rExp, rPot)
    dBestR = max(rLin, rCuad, rExp, rPot)
    if dBestR == rLin then
        sBest = "lineal"
        funWin = linFun
    end
    if dBestR == rCuad then
        sBest = "cuadrático"
        funWin = cuadFun
    end
    if dBestR == rExp then
        sBest = "exponencial"
        funWin = expFun
    end
    if dBestR == rPot then
        sBest = "potencial"
        funWin = potFun
    end
endfunction

////////////////////////////////////////
// calcR
// Calcula el valor de r² dado un vector de valores x, y, y la función de
// regresión utilizada
// Parametros:
// 	func: La función de regresión que se utilizará para calcular la regresión
// 	dArrX: Un vector que contiene los valores X
// 	dArrY: Un vcector que contiene los valores Y
// Retorno:
// 	dRsq: valor de la R cuadrada de la función correspondiente (aplicabe en lineal y cuadrática)
////////////////////////////////////////
function dRsq = calcR(func, dArrX, dArrY)
    dSST = sum((dArrY - mean(dArrY))^2)
    dSSR = sum((dArrY - func(dArrX) )^2)
    dRsq = 1 - (dSSR / dSST)
endfunction

////////////////////////////////////////
// calcRLogs
// Calcula el valor de r² dado un vector de valores x, y, y la función de
// regresión utilizada. Usar con regresiones exponenciales y de potencia
// Parametros:
// 	func: La función de regresión que se utilizará para calcular la regresión
// 	dArrX: Un vector que contiene los valores X
// 	dArrY: Un vcector que contiene los valores Y
// Retorno:
// 	dRsq: valor de la R cuadrada de la función correspondiente
////////////////////////////////////////
function dRsq = calcRLogs(func, dArrX, dArrY)
    dSST = sum((log(dArrY) - mean(log(dArrY)))^2)
    dSSR = sum((log(dArrY) - log(func(dArrX)) )^2)
    dRsq = 1 - (dSSR / dSST)
endfunction

////////////////////////////////////////
// cuadReg
// Esta función crea la matriz correspondiente a la función cuadrática y 
// obtiene la ecuación de la regresión correspondiente
// Parametros:
// 	dArrX: Un vector que contiene los valores X
// 	dArrY: Un vcector que contiene los valores Y
// Retorno:
// 	anCuad: un vector con los valores de la función 
////////////////////////////////////////
function anCuad = cuadReg(dArrX, dArrY)
    mat = [length(dArrX), sum(dArrX), sum(dArrX^2), sum(dArrY);
           sum(dArrX), sum(dArrX^2), sum(dArrX^3), sumaDiag(dArrY' * dArrX);
           sum(dArrX^2), sum(dArrX^3), sum(dArrX^4), sumaDiag(dArrY' * (dArrX^2))]
      mat = gaussJordan(mat), 
      anCuad = mat(:,4) 
endfunction

////////////////////////////////////////
// expReg
// Esta función crea la matriz correspondiente a la función exponencial y 
// obtiene la ecuación de la regresión correspondiente
// Parametros:
// 	dArrX: Un vector que contiene los valores X
// 	dArrY: Un vcector que contiene los valores Y
// Retorno:
// 	anExp: un vector con los valores de la función
////////////////////////////////////////
function anExp = expReg(dArrX, dArrY)
   dMat = [length(dArrX), sum(dArrX), sum(log(dArrY));
           sum(dArrX), sum(dArrX^2), sumaDiag(log(dArrY') * dArrX)]
    dMat = gaussJordan(dMat)
anExp = dMat(:,3)
endfunction

////////////////////////////////////////
// anPot
// Esta función crea la matriz correspondiente a la función cuadrática y 
// obtiene la ecuación de la regresión
// Parametros:
// 	dArrX: Un vector que contiene los valores X
// 	dArrY: Un vcector que contiene los valores Y
// Retorno:
// 	anPot: un vector con los valores de la función
////////////////////////////////////////
function anPot = potReg(dArrX,dArrY) 
    dMat = [length(dArrX), sum(log(dArrX)), sum(log(dArrY));
           sum(log(dArrX)), sum((log(dArrX))^2), sumaDiag(log(dArrX) * log(dArrY'))]
    dMat = gaussJordan(dMat)
    anPot = dMat(:,3)
endfunction

////////////////////////////////////////
// calcAnormales
// Esta función encuentra los valores atípicos con respecto a la mejor 
// regresión utilizando la regla del 1.5 usando rangos intercuartiles
// Parametros:
// 	dArrX: Un vector que contiene los valores X
// 	dArrY: Un vcector que contiene los valores Y
// 	funWin: La función con mejor R cuadrada
// Retorno:
// 	dAtyplical: lista cuyos elementos corresponden a los puntos con datos atípicos
////////////////////////////////////////
function dAtypical = calcAnormales(dArrX, dArrY, funWin)
    dDistances = []
    
    for i = 1 : size(dArrX, 1)
        dDistances(i) = (dArrY(i) - funWin(dArrX(i)))**2
    end
    
    dQuartiles = quart(dDistances)
    dRange = dQuartiles(3) - dQuartiles(1)
    dDownLimit = dQuartiles(1) - (1.5 * dRange)
    dUpLimit = dQuartiles(3) + (1.5 * dRange)
    
    iIndex = 1
    dAtypical = tlist(["listtype","X","Y"], [], [])
    for i = 1 : size(dArrX, 1)
        if dDistances(i) > dUpLimit | dDistances(i) < dDownLimit then
            dAtypical.X(iIndex) = dArrX(i)
            dAtypical.Y(iIndex) = dArrY(i)
            iIndex = iIndex + 1
        end
    end
endfunction

////////////////////////////////////////
// outputFile
// Le pide al usuario el nombre del arhivo con el que quiere generar el output
// y lo escribe, utilizando la función dada
// Parámetros:
//  fun: La funcion con la que se escribirá el archivo
// Retorno:
//  NONE, pero escribe un archivo al disco
////////////////////////////////////////
function outputFile(fun, dToEval)
    sFileName = input("¿Cómo quisiera llamar el archivo con los resultados? ", "string")
    if grep(sFileName, '/.*\.csv$/', 'r') == []  then
        sFileName = sFileName + '.csv'
    end
    disp("Generando archivo " + sFileName)
    write_csv(string(cat(1,fun(dArrY),fun(dToEval))), sFileName) 
endfunction

/////////////////////////////////////main//////////////////////////////////////
//Pedir archivo .xls
[dArrX,dArrY] = getFile()
dToEval = input("¿En que valor desea calcular la regresión? ")

////obtener regresiones y su R cuadrada

//obtener regresion lineal
deff('an= linFun(dArrX)', 'an = iLinM*dArrX + iLinB')
[iLinM,iLinB, dSigLin]  = reglin(dArrX',dArrY')
rLin = calcR(linFun, dArrX, dArrY)

//regresion cuadratica

anCuad = cuadReg(dArrX, dArrY)
deff('an = cuadFun(dArrX)', 'an = anCuad(1) + (anCuad(2) * dArrX) + (anCuad(3) * (dArrX^2))')
rCuad = calcR(cuadFun, dArrX, dArrY)

//regresion exponencial 
deff('regAnsExp = expFun(dArrX)', 'regAnsExp = %e ^anExp(1) * %e ^ (anExp(2) * dArrX)' )
anExp = expReg(dArrX, dArrY)
rExp = calcRLogs(expFun, dArrX, dArrY)

//regresion de potencia
anPot = potReg(dArrX, dArrY)
deff('an = potFun(dArrX)', 'an = (%e ^ anPot(1)) * dArrX ^ anPot(2)' )
rPot = calcRLogs(potFun, dArrX, dArrY)

//mostrar seccion I, las formulas de regresion con su R cuadrada
disp("- Lineal     :  y = (" + string(iLinB) + ") + (" + string(iLinM) + ") * x, r^2 = "+ string(rLin))
disp("- Cuadrático :  y = (" + string(anCuad(1)) + ") + (" + string(anCuad(2)) + ") * x + (" + string(anCuad(3)) + ") * x ^ 2, r^ 2 = " + string(rCuad))
disp("- Exponencial:  y = (" + string((%e ^ anExp(1))) + ") * e ^ ((" + string(anExp(2)) + ") * x), r ^ 2 = " + string(rExp))
disp("- Potencial  :  y = (" + string((%e ^ anPot(1))) + ") * x ^ (" + string(anPot(2)) + "), r ^ 2 = " + string (rPot))


//mostrar las conclusiones
[dBestR,sBest, funWin] = dGetR(rLin, rCuad, rExp, rPot)

disp("- El mejor modelo será el " + sBest + ", con una r^2 de " + string(dBestR))

dTemp = 0

disp("Usando cada modelo, los valores estimados para x = " + string(dToEval) + " serán:")
dTemp = linFun(dToEval)
disp("      -Lineal      : " + string(dTemp))
dTemp = cuadFun(dToEval)
disp("      -Cuadrático  : " + string(dTemp))
dTemp = expFun(dToEval)
disp("      -Exponencial : " + string(dTemp))
dTemp = potFun(dToEval)
disp("      -Potencial   : " + string(dTemp))

//calcAnormales
//funWin es la función que ganó en la regresión
dAtypical = calcAnormales(dArrX, dArrY, funWin)

disp("De acuerdo con los cuadrados de las distancias entre cada punto y el modelo " + sBest + ", existen valores anormales:")
for i = 1 : size(dAtypical.Y,1)
    disp( "(" + string(dAtypical.X(i)) + ", " + string(dAtypical.Y(i)) + ")")
end

//Generar plots 
bigNum = max(dArrX, dToEval)
bigNum = bigNum(1) + 5
iPlotPoints = [0:1:bigNum]
plot(iPlotPoints, linFun(iPlotPoints),"b", 'LineWidth', 2)
plot(iPlotPoints, cuadFun(iPlotPoints),"g", 'LineWidth', 2)
plot(iPlotPoints, expFun(iPlotPoints),"r", 'LineWidth', 2)
plot(iPlotPoints, potFun(iPlotPoints),"black", 'LineWidth', 2)
points = scatter(dArrX, dArrY, "black", "x")
xtitle ( "Regresiones" , "X axis" , "Y axis" )
legend("Lineal","Cuadrático","Exponencial", "Potencial")

//generar nuevo .xls
outputFile(funWin, dToEval)

