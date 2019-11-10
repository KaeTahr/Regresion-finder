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

/////////////////main////////////////
//Pedir archivo .xls
//data = getFile()

// example data
x = [20, 30 , 10, 40, 50]
y = [15, 12, 25, 30, 5]


//obtener regresiones y su R
//obtener regresion lineal
deff('an= linFun(x)', 'an = iLinM*x + iLinB')
[iLinM,iLinB, sig]  = reglin(x,y)
//TODO: find r²

//regresion cuadratica

//regresion exponencial

//regresion de potencia

//mostrar la regresion con la mejor R

//generar nuevo .xls
