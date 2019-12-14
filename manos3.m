%***************************************************
%AUTORES:
%Pau Rodríguez Inserte
%David Vizcarro Carretero
%***************************************************

%CAMBIAR DIRECTORIOS, TEST PARA EVALUAR UN SET COMPLETO DE IMAGENES
clc;
clear all;
close all;

tic;
%cd('C:\Users\piv115\Desktop\detector_manos');
skin_data=matfile('skin_data.mat','Writable',false);
hist=skin_data.hist;
cd('Training-Dataset/Images');
%cd('C:\Users\piv115\Desktop\detector_manos\Test-Dataset\Test-Images');

%Mediante el histograma total y definiendo un threshold, obtenemos una
%versión preliminar de la máscara, defieniendo a partir de que nivel 
%consideraremos que un pixel es de piel o no.

threshold = 6396;
binary = hist;
for i = 1:255
    for j = 1:255
        if binary(i,j) > threshold
            binary(i,j) = 1;
        else
            binary(i,j) = 0;
        end
    end
end

nearones = 0;
nearzeros = 0;
th = 4;
% th1 = 5;

%Procurando no salir de los margénes de la matriz del histograma,
%intentaremos interpolar los puntos en el histograma que sean piel pero 
%que hayan escapado al threshold. Para ello miramos si el punto a evaluar
%queda por debajo del threshold, y si se encuentra rodeado en todas las
%direcciones por "piel", entonce le asignamos automáticamente el valor de
%piel a ese pixel.

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


Files=dir();

score_tot=(zeros(1,length(Files)-2));
precision_tot=(zeros(1,length(Files)-2));
recall_tot=(zeros(1,length(Files)-2));

for k=3:length(Files)
   
   
   filename=Files(k).name;
   ima = imread(filename);

    ycroma = double(rgb2ycbcr(ima));
    cbima = ycroma(:,:,2);
    crima = ycroma(:,:,3);
    [lx,ly,lz] = size(ima);

    mascara = zeros(lx,ly);



%     for i = 2:lx-1
%         for j = 2:ly-1
%             if mascara(i,j) == 255
%                 if mascara(i+1,j) == 0
%                     nearones = nearones+1;
%                 end
%                 if mascara(i-1,j) == 0
%                     nearones = nearones+1;
%                 end
%                 if mascara(i,j+1) == 0
%                     nearones = nearones+1;
%                 end
%                 if mascara(i,j-1) == 0
%                     nearones = nearones+1;
%                 end
% 
%                 if mascara(i+1,j+1) == 0
%                     nearones = nearones+1;
%                 end
%                 if mascara(i-1,j-1) == 0
%                     nearones = nearones+1;
%                 end
%                 if mascara(i-1,j+1) == 0
%                     nearones = nearones+1;
%                 end
%                 if mascara(i+1,j-1) == 0
%                     nearones = nearones+1;
%                 end
% 
%                 if mascara >= 5
%                     binary(i,j) = 255;
%                 end
%                 nearones = 0;
% 
%             else
%                 if mascara(i+1,j) == 255
%                     nearzeros = nearzeros+1;
%                 end
%                 if mascara(i-1,j) == 255
%                     nearzeros = nearzeros+1;
%                 end
%                 if mascara(i,j+1) == 255
%                     nearzeros = nearzeros+1;
%                 end
%                 if mascara(i,j-1) == 255
%                     nearzeros = nearzeros+1;
%                 end
% 
%                 if mascara(i+1,j+1) == 255
%                     nearzeros = nearzeros+1;
%                 end
%                 if mascara(i-1,j-1) == 255
%                     nearzeros = nearzeros+1;
%                 end
%                 if mascara(i-1,j+1) == 255
%                     nearzeros = nearzeros+1;
%                 end
%                 if mascara(i+1,j-1) == 255
%                     nearzeros = nearzeros+1;
%                 end
% 
%                 if mascara >= 5
%                     binary(i,j) = 255;
%                 end
%                 nearzeros = 0;
%             end
%         end
%     end
    for i = 1:lx
        for j = 1:ly
            if binary(cbima(i,j),crima(i,j)) == 1
                mascara(i,j) = 0;
            else
                mascara(i,j) = 255;
            end
         end
    end
    cd('../../');
    filename=erase(filename,".jpg");
    savemask(mascara, filename);
    [score,precision,recall] = fscore(filename);
    score_tot(k-2)=score;
    precision_tot(k-2)=precision;
    recall_tot(k-2)=recall;
end
time=toc;
f_score=sum(score_tot)/length(Files)
precision=sum(precision_tot)/length(Files)*100
recall=sum(recall_tot)/length(Files)*100

time
%cd('C:\Users\piv115\Desktop\detector_manos');
save('final_test_1','time','f_score','precision','recall');
