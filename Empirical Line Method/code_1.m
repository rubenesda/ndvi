clear 
close all
numpre = '05'; %Anteprefijo del nombre del archivo
pre = '-read'; %Prefijo del nombre del archivo
suf = '.asd.txt'; %Extención del archivo.
begin = 1; %Número inicial donde empieza las medidas espectrales NOTA: puede variarlo a conveniencia.
data = []; %Matriz vacia donde se almacenará la data de medidas espectrales de 325 nm a 1075 nm
miss = []; %Matriz vacia donde se almacenará datos espectrales que están olvidadas en la "data" y pasaron a ser "textdata".
for i = 1:10
    s = importdata(strcat(numpre,pre,num2str(begin+(i-1)),suf)); %Se importa los datos del archivo .asd.txt del ASD en variable matlab
    if(length(s.data(:,2))<751) %Se verifica si la longitud de la matriz de la data es correcta, de lo contrario, indica que hay datos perdidos en la data y están en el textdata.
        num = 751 - length(s.data(:,2)); %Se comprueba cuanta es la cantidad de datos perdidos al inicio (Se encontró que los datos que se omiten en la data y pasan al textdata son los que inician desde 325 nm. Ejemplo, si faltan 3 datos en data quiere decir que en "data" faltan los datos 325, 326 y 327, los cuales estan en "textdata".
        for j = 2:num+1 %Inicialización del ciclo de llenado de la matriz miss, empieza en 2 ya que en la posición inicial de "textdata" están los encabezados de las columnas de "data" que son 'Wavelength' y 'SpectrumXXX.asd' Los cuales no se pueden convertir en valores numericos.
           miss = [miss;str2num(s.textdata{j}(5:end))]; %Se llena o se concatena la matriz miss, donde cada dato perdido se obvia los 4 primero caracteres del string, porque corresponden a la longitud de onda correspondiente y por el momento este dato no es necesario.
        end
        data = [data, [miss;s.data(:,2)]]; %Finalmente la matriz se concatena con la anterior y así sucesivamente.
        miss = [];
    else
        data = [data, [s.data(:,2)]]; %En caso de que la longitud del "data" esté correcto que sea igual que el anterior por tanto se concatena normalmente.   
    end %Fin condicional de la longitud de "data"
end %Fin del ciclo de concatenado de las primeras 10 mediciones espectrales con 10 angulos diferentes para un solo target.
[p,tbl,stats] = anova1(data(77:576,:)); %Se realiza en analiza del ANOVA
% de los datos que se extrayeron. Se acotan desde 400 nm hasta 900 nm que
% son el index 76 y 576 respectivamente, ya que los datos o longitudes de
% onda por debajo de 400 nm son luz ultravioleta y si estás en un cuearto
% usando lamparas halógenas ellas no son capaces de emitirlas por tanto 
% hay mucho ruido, si fuera en campo abierto con luz solar no habría ese
% ruido porque el sol contiene el espectro completo. Por otro lado, por
% encima de los 900 nm la lampara halógena contiene poco del infrarrojo 
% por lo tanto hay ruido. 
% currentpath = cd('..')
cd % Muestra en pantalla la ubicación de los datos.
stats.means %mostrar estadistica de los datos, para verificar que las medias son parecidas
mean = []; %Crea un vector vacio para guardar los datos de la curva media de todas las curvas
sum=0; %Variable para acumular la suma de cada dato a medida que se recorra los vectores
for i=1:length(data) %Establece la longitud del ciclo for
    for j =1:10 % El 10 es un número que corresponde a la cantidad de lecturas espectrales que tengamos, ejemplo: si tenemos 15 medidas espectrales será 15 en vez de 10.
        sum = sum+data(i,j); %Se realiza la suma y va acumulando en cada iteración.
    end
    mean(i)=sum/10; %Realiza la media, nuevamente el 10 puede cambiarse. Ejemplo: si tenemos 15 lecturas espectrales ese 10 se debe cambiar por 15.
    sum=0; %Dado que es una matriz iXj, la suma recorre por renglón, sumando todas los componentes del renglón i y divide por la cantidad de datos en ese renglón para determinar la media de ese rengón, los datos del rengón son igual número a la lecturas espectrales, una vez sumadas se reinicia la variable sum para seguír con el siguiente renglón.
end
figure(3) %Se crea un canvas nuevo, es el número tres porque los dos primeros están ocupados por el analísis del ANOVA.
x=325:1:1075; %Se establece el vector x correspondiente a las longitudes de onda que puede medir el espectro radiomentro Field Hand Held 2, si el espectro radiometro puede medir más, el usuario debe cambiar los límites de ésta línea de código.
plot(x,mean);xlabel('Wavelength (nm)');ylabel('Reflectance'); title(strcat('Target-',numpre,' %')) %Se muestra la gráfica.

figure(4) %Creación de otro canvas.
for i=1:10 %El número 10 puede cambiar, recordar que pertenece a la cantidad de lecturas espectrales realizadas si fueron 20 éste número debe cambiar a 20 y así sucesivamente.
   plot(x,data(:,i), 'color', [0.5 0.5 0.5]) %Se grafica cada lectura espectral y se coloca de color grís.
   hold on %Se retiene la curva anterior para que el nuevo plot no la borre y se mantenga.
end
p1= plot(x,mean,'k','LineWidth',1.5);xlabel('Wavelength (nm)');ylabel('Reflectance'); title(strcat('Target-',numpre,' %')) %Se suporpone la curva 'mean' sobre las demas, para mostrar al lector la ubicación de la 'mean' y que note el contraste con los demas.
axis([400 900 0.2 0.5]) %Se ajusta los límites de visualización del plot, recordad que por debajo de 400 si estás en un cuarto oscuro con lámparas halógenas no contienen luz ultravioleta por lo tanto es ruido al igual que por encima de 900 nm no tiene infrarojo por ende también es ruido. 
legend(p1,'Mean') %Solo para mostrar en la legenda la media.

% filename = '20-percent.mat' %Nombre del archivo a guardar. 
filename = strcat(numpre,'-percent-statis.mat') %guardar la estadistica de los datos adquiridos de means.
save(filename) %Guarda todas las variables del workspace en un archivo.mat
save(strcat(numpre,'-mean.mat'),'mean') %Se guarda una unica variable la media para éste target en cuestión.
%NOTA: No se puede usar el test estadistico del Colmogorov (kstats()) porque los datos tomados con el espectro radiometro son no parametricos y no provienen de una distribución Gausssiana o normal.
p = kruskalwallis(data(77:576,:)) %Se ejecuta el test estadístico Kruskal - Wallis para reconfirmar si el target que se annalizó con el ANOVA también acierta en el ANOVA del Kruskal - Wallis, de ser correcto, quiere decir que el target posee una superficie lambertiana la hipótesis nula de que las reflectancia es indiferente de la angulo de medida y que las lecturas vienen de una misma distribución.
