clear

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

function dSum = sumaDiag(dMat)
    dSum = 0
    for iIndex = 1 : size(dMat,1)
        dSum = dMat(iIndex, iIndex) + dSum
    end
endfunction

function dRsq = calcR(func, dArrX, dArrY)
    SST = sum((dArrY - mean(dArrY))^2)
    SSR = sum((dArrY - func(dArrX) )^2)
    dRsq = 1 - (SSR / SST)
endfunction

function dRsq = calcRLogs(func, dArrX, dArrY)
    SST = sum((log(dArrY) - mean(log(dArrY)))^2)
    SSR = sum((log(dArrY) - log(func(dArrX)) )^2)
    dRsq = 1 - (SSR / SST)
endfunction

/////////////////main////////////////
//Pedir archivo .xls
[dArrX,dArrY] = getFile()

//obtener regresiones y su R cuadrada

//obtener regresion lineal
deff('an= linFun(dArrX)', 'an = iLinM*dArrX + iLinB')
[iLinM,iLinB, dSigLin]  = reglin(dArrX',dArrY')

    //obtener R cuadrada de lineal
rLin = calcR(linFun, dArrX, dArrY)

//regresion cuadratica
function anCuad = cuadReg(dArrX, dArrY)
    mat = [length(dArrX), sum(dArrX), sum(dArrX^2), sum(dArrY);
           sum(dArrX), sum(dArrX^2), sum(dArrX^3), sumaDiag(dArrY' * dArrX);
           sum(dArrX^2), sum(dArrX^3), sum(dArrX^4), sumaDiag(dArrY' * (dArrX^2))]
      mat = gaussJordan(mat), 
      anCuad = mat(:,4) 
endfunction

anCuad = cuadReg(dArrX, dArrY)

deff('an = cuadFun(dArrX)', 'an = anCuad(1) + (anCuad(2) * dArrX) + (anCuad(3) * (dArrX^2))')

rCuad = calcR(cuadFun, dArrX, dArrY)

//regresion exponencial 
function anExp = expReg(dArrX, dArrY)
    mat = [length(dArrX), sum(dArrX), sum(log(dArrY));
           sum(dArrX), sum(dArrX^2), sumaDiag(log(dArrY') * dArrX)]
    mat = gaussJordan(mat)
anExp = mat(:,3)
endfunction


deff('regAnsExp = expFun(dArrX)', 'regAnsExp = %e ^anExp(1) * %e ^ (anExp(2) * dArrX)' )
anExp = expReg(dArrX, dArrY)

rExp = calcRLogs(expFun, dArrX, dArrY)

//regresion de potencia
function anPot = potReg(dArrX,dArrY) 
    mat = [length(dArrX), sum(log(dArrX)), sum(log(dArrY));
           sum(log(dArrX)), sum((log(dArrX))^2), sumaDiag(log(dArrX) * log(dArrY'))]
    mat = gaussJordan(mat)
    anPot = mat(:,3)
endfunction

anPot = potReg(dArrX, dArrY)

deff('an = potFun(dArrX)', 'an = (%e ^ anPot(1)) * dArrX ^ anPot(2)' )

rPot = calcRLogs(potFun, dArrX, dArrY)

//mostrar seccion I, las formulas de regresion con su R cuadrada
disp("- Lineal     :  y = (" + string(iLinB) + ") + (" + string(iLinM) + ") * x, r^2 = "+ string(rLin))
disp("- Cuadrático :  y = (" + string(anCuad(1)) + ") + (" + string(anCuad(2)) + ") * x + (" + string(anCuad(3)) + ") * x ^ 2, r^ 2 = " + string(rCuad))
disp("- Exponencial:  y = (" + string((%e ^ anExp(1))) + ") * e ^ ((" + string(anExp(2)) + ") * x), r ^ 2 = " + string(rExp))
disp("- Potencial  :  y = (" + string((%e ^ anPot(1))) + ") * x ^ (" + string(anPot(2)) + "), r ^ 2 = " + string (rPot))


//mostrar las conclusiones
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

[dBestR,sBest, funWin] = dGetR(rLin, rCuad, rExp, rPot)

disp("- El mejor modelo será el " + sBest + ", con una r^2 de " + string(dBestR))

dTemp = 0

disp("Usando cada modelo, los valores estimados para x = 60 serán:")
dTemp = linFun(60)
disp("      -Lineal      : " + string(dTemp))
dTemp = cuadFun(60)
disp("      -Cuadrático  : " + string(dTemp))
dTemp = expFun(60)
disp("      -Exponencial : " + string(dTemp))
dTemp = potFun(60)
disp("      -Potencial   : " + string(dTemp))

//calcAnormales
//funWin es la función que ganó en la regresión

disp("De acuerdo con los cuadrador de las distancias entre cada punto y el modelo exponencial, existen valores anormales:")

//Generar plots con PLOTLY
xD = [0:1:60]
plot(xD, linFun(xD),"b", 'LineWidth', 2)
plot(xD, cuadFun(xD),"g", 'LineWidth', 2)
plot(xD, expFun(xD),"r", 'LineWidth', 2)
plot(xD, potFun(xD),"black", 'LineWidth', 2)
points = scatter(dArrX, dArrY, "black", "x")
xtitle ( "Regresiones" , "X axis" , "Y axis" )
legend("Lineal","Cuadrático","Exponencial", "Potencial")

//generar nuevo .xls
function outputFile(fun)
    sFileName = input("¿Cómo quisiera llamar el archivo con los resultados? ", "string")
    if grep(sFileName, '/.*\.csv$/', 'r') == []  then
        sFileName = sFileName + '.csv'
    end
    disp("Generando archivo " + sFileName + '…')
    write_csv(string(fun(dArrY)), sFileName)  
endfunction

outputFile(funWin)

