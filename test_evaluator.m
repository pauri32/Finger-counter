%***************************************************
%AUTORES:
%Pau Rodríguez Inserte
%David Vizcarro Carretero
%***************************************************

clc;
clear all;
close all;

%Este programa realiza la misma función, que skin_data_obtention, solo que
%lo hace para todo un set completo de imágenes y guarda los resultados
%deseados en un fichero 'final_test_1'

tic;

cd('C:\Users\Patron\Desktop\pruebas');
skin_data=matfile('skin_data.mat','Writable',false);
hist=skin_data.hist;
binary=skin_data.binary;
threshold = 6936;

%cd('C:\Users\Patron\Desktop\pruebas\Validation-Dataset\Images')
cd('C:\Users\Patron\Desktop\pruebas\Test-Dataset\Test-Images');
addpath 'C:\Users\Patron\Desktop\pruebas'
Files=dir();

 tot_t_pos=0;
 tot_t_neg=0;
 tot_f_pos=0;
 tot_f_neg=0;

%Para cada una de las imagenes del set de validación, encontramos el umbral
%más cercano al óptimo y lo guardamos en un vector de umbrales optimos.
%Tras calcularlos todos, les hacemos la media y obtenemos que el umbral
%óptimo medio es el 6396. El tiempo de ejecución es de unos 20 min.

for k=3:length(Files)
   filename=Files(k).name;
   %cd('../../');        
   %cd('C:\Users\Patron\Desktop\pruebas\Validation-Dataset\Images');
   cd('C:\Users\Patron\Desktop\pruebas\Test-Dataset\Test-Images');
   ima = imread(filename);
   ycroma = double(rgb2ycbcr(ima));
   cbima = ycroma(:,:,2);
   crima = ycroma(:,:,3);
   [lx,ly,lz] = size(ima);
   mascara = zeros(lx,ly);
 
   nearones = 0;
   nearzeros = 0;
   th = 4;
   for i = 2:254
        for j = 2:254
            if binary(i,j) < threshold
                if binary(i+1,j) == 1
                    nearones = nearones+1;
                end
                if binary(i-1,j) == 1
                    nearones = nearones+1;
                end
                if binary(i,j+1) == 1
                    nearones = nearones+1;
                end
                if binary(i,j-1) == 1
                    nearones = nearones+1;
                end

                if binary(i+1,j+1) == 1
                    nearones = nearones+1;
                end
                if binary(i-1,j-1) == 1
                    nearones = nearones+1;
                end
                if binary(i-1,j+1) == 1
                    nearones = nearones+1;
                end
                if binary(i+1,j-1) == 1
                    nearones = nearones+1;
                end

                if nearones >= th
                    binary(i,j) = 1;
                end
                nearones = 0;
            end
        end
    end

    for i = 1:lx
        for j = 1:ly
            if binary(cbima(i,j),crima(i,j)) == 1
                mascara(i,j) = 0;
            else
                mascara(i,j) = 255;
            end
         end
    end
    %se=strel('square',11);
    se=strel('disk',2,8);
    %mascara=imclose(imopen(mascara,se),se);
    mascara=medfilt2(imopen(imclose(mascara,se),se));
    cd('../../');
    %imshow(mascara);
    filename=erase(filename,".jpg");
    savemask(mascara, filename);
    [true_positive,true_negative,false_positive,false_negative] = fscore(filename);
    tot_t_pos=tot_t_pos+true_positive;
    tot_t_neg=tot_t_neg+true_negative;
    tot_f_pos=tot_f_pos+false_positive;
    tot_f_neg=tot_f_neg+false_negative;

end

true_positive = tot_t_pos;
true_samples = tot_t_pos+tot_f_neg;
positive_samples = tot_t_pos+tot_f_pos;
    
precision = true_positive/positive_samples
recall = true_positive/true_samples
score = 2*((precision*recall)/(precision+recall))

time=toc;
time

save('final_test_1','score','precision','recall','time');

