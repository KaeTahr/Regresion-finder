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
    

//Haciendo y transpuesta para las operaciones en scilab
y = y'

//regresion cuadratica
deff('respCuad = cuadFun(vect, x)', 'respCuad = vect(1) + (vect(2) * x) + (vect(3) * (x^2))')

deff('anCuad = cuadReg(x, y)', 'mat = [length(x), sum(x), sum(x^2), sum(y); sum(x), sum(x^2), sum(x^3), sumaDiag(y * x); sum(x^2), sum(x^3), sum(x^4), sumaDiag(y * (x^2))], mat = gaussJordan(mat), anCuad = mat(:,4)') 
anCuad = cuadReg(x, y)
anCuad

    //obtener R cuadrada de cuadratica
//deff('rCuad = rFunCuad(anExp, x, y)', 'SST = sum((y - mean(y))^2), SSR = sum((y - cuadFun(anCuad, x))^2), rCuad = 1 - (SSR / SST)')
//rCuad = rFunCuad(anCuad, x, y)

//regresion exponencial
deff('respExp = expFun(vect,x)', ' respExp = (%e ^ vect(1)) * %e ^ (vect(2) * x)')

deff('anExp = expReg(x, y)', 'mat = [length(x), sum(x), sum(log(y)); sum(x), sum(x^2), sumaDiag(log(y) * x)], mat = gaussJordan(mat), anExp = mat(:,3)')
anExp = expReg(x, y)

    //obtener R cuadrada de exponencial
//deff('rExp = rFunExp(anExp, x, y)', 'SST = sum(y - mean(y)), SSR = sum(y - expFun(anExp, x)), rExp = 1 - (SSR / SST)')
//rExp = rFunExp(anExp, x, y)

//regresion de potencia
deff('respPot = potFun(vect, x)', 'respPot = (%e ^ vect(1)) * x ^ vect(2)')

deff('anPot = potReg(x,y)', 'mat = [length(x), sum(log(x)), sum(log(y)); sum(log(x)), sum((log(x))^2), sumaDiag(log(x) * log(y))], mat = gaussJordan(mat), anPot = mat(:,3)')
anPot = potReg(x, y)

    //obtener R cuadrada de potencia
//deff('rPot = rFunPot(anExp, x, y)', 'SST = sum(y - mean(y)), SSR = sum(y - potFun(anPot, x)), rPot = 1 - (SSR / SST)')
//rPot = rFunPot(anPot, x, y)

//mostrar seccion I, las formulas de regresion con su R cuadrada
disp("- Lineal     :  y = (" + string(iLinB) + ') + (' + string(iLinM) + ') * x')
disp("- Cuadrático :  y = (" + string(anCuad(1)) + ") + (" + string(anCuad(2)) + ") * x + (" + string(anCuad(3)) + ") * x ^ 2, r^ 2 = ")
disp("- Exponencial:  y = (" + string((%e ^ anExp(1))) + ") * e ^ ((" + string(anExp(2)) + ") * x), r ^ 2 = ")
disp("- Potencial  :  y = (" + string((%e ^ anPot(1))) + ") * x ^ (" + string(anPot(2)) + "), r ^ 2 = ")


//mostrar las conclusiones

//generar nuevo .xls
