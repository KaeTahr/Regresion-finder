clear

//function data = getFile()
//    sFileName = input("Cuál es el nombre del archivo .xls? ", "string")
//    if grep(sFileName, '/.*\.xls$/', 'r') == []  then
//        sFileName = strcat(sFileName, '.xls')
//    end
//
//    data = readxls(sFileName)
    //TODO: parse data
//endfunction

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

function dRsq = calcR(func, x, y)
    SST = sum((y - mean(y))^2)
    SSR = sum((y - func(x) )^2)
    dRsq = 1 - (SSR / SST)
endfunction

function dRsq = calcRLogs(func, x, y)
    SST = sum((log(y) - mean(log(y)))^2)
    SSR = sum((log(y) - log(func(x)) )^2)
    dRsq = 1 - (SSR / SST)
endfunction

/////////////////main////////////////
//Pedir archivo .xls
//data = getFile()

17.4

// example data
x = [20, 30 , 10, 40, 50]
y = [15, 12, 25, 30, 5]


//obtener regresiones y su R cuadrada

//obtener regresion lineal
deff('an= linFun(x)', 'an = iLinM*x + iLinB')
[iLinM,iLinB, sig]  = reglin(x,y)

    //obtener R cuadrada de lineal
rLin = calcR(linFun, x, y)

//Haciendo y transpuesta para las operaciones en scilab

inverseY = y'

//regresion cuadratica
deff('anCuad = cuadReg(x, y)', 'mat = [length(x), sum(x), sum(x^2), sum(y); sum(x), sum(x^2), sum(x^3), sumaDiag(y * x); sum(x^2), sum(x^3), sum(x^4), sumaDiag(y * (x^2))], mat = gaussJordan(mat), anCuad = mat(:,4)') 
anCuad = cuadReg(x, y')
anCuad

deff('an = cuadFun(x)', 'an = anCuad(1) + (anCuad(2) * x) + (anCuad(3) * (x^2))')

rCuad = calcR(cuadFun, x, y)

//regresion exponencial 
deff('anExp = expReg(x, y)', 'mat = [length(x), sum(x), sum(log(y)); sum(x), sum(x^2), sumaDiag(log(y) * x)], mat = gaussJordan(mat), anExp = mat(:,3)')


deff('regAnsExp = expFun(x)', 'regAnsExp = %e ^anExp(1) * %e ^ (anExp(2) * x)' )
anExp = expReg(x, y')

rExp = calcRLogs(expFun, x, y)

//regresion de potencia
deff('anPot = potReg(x,y)', 'mat = [length(x), sum(log(x)), sum(log(y)); sum(log(x)), sum((log(x))^2), sumaDiag(log(x) * log(y))], mat = gaussJordan(mat), anPot = mat(:,3)')
anPot = potReg(x, y')

deff('an = potFun(x)', 'an = (%e ^ anPot(1)) * x ^ anPot(2)' )

rPot = calcRLogs(potFun, x, y)

//mostrar seccion I, las formulas de regresion con su R cuadrada
disp("- Lineal     :  y = (" + string(iLinB) + ') + (' + string(iLinM) + ') * x, r^2 = '+string(rLin))
disp("- Cuadrático :  y = (" + string(anCuad(1)) + ") + (" + string(anCuad(2)) + ") * x + (" + string(anCuad(3)) + ") * x ^ 2, r^ 2 = " + string(rCuad))
disp("- Exponencial:  y = (" + string((%e ^ anExp(1))) + ") * e ^ ((" + string(anExp(2)) + ") * x), r ^ 2 = " + string(rExp))
disp("- Potencial  :  y = (" + string((%e ^ anPot(1))) + ") * x ^ (" + string(anPot(2)) + "), r ^ 2 = " + string (rPot))


//mostrar las conclusiones
function [dBestR,sBest] = dGetR(rLin, rCuad, rExp, rPot)
    dBestR = max(rLin, rCuad, rExp, rPot)
    if dBestR == rLin then
        sBest = "lineal"
    end
    if dBestR == rCuad then
        sBest = "cuadrático"
    end
    if dBestR == rExp then
        sBest = "exponencial"
    end
    if dBestR == rPot then
        sBest = "potencial"
    end
    
endfunction

[dBestR,sBest] = dGetR(rLin, rCuad, rExp, rPot)

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

disp("De acuerdo con los cuadrador de las distancias entre cada punto y el modelo exponencial, existen valores anormales:")

//Generar plots con PLOTLY
xD = [0:1:60]
plot(xD, linFun(xD),"b", 'LineWidth', 2)
plot(xD, cuadFun(xD),"g", 'LineWidth', 2)
plot(xD, expFun(xD),"r", 'LineWidth', 2)
plot(xD, potFun(xD),"black", 'LineWidth', 2)
xtitle ( "Regresiones" , "X axis" , "Y axis" )
legend("Lineal","Cuadrático","Exponencial", "Potencial")

//generar nuevo .xls
