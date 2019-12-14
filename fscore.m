%***************************************************
%AUTORES:
%Pau Rodríguez Inserte
%David Vizcarro Carretero
%***************************************************

function [score,precision,recall]= fscore(filename)

    %Cargamos las máscaras real e ideal
    
    cd('Training-Dataset/Masks-Ideal');
    idealmask = double(imread(horzcat(filename,'.bmp')));
    cd('../Masks');
    newmask = double(imread(horzcat(filename,'.bmp')))./255;
    
    true_positive = 0;
    true_negative = 0;
    false_positive = 0;
    false_negative = 0;
     
    precision = 0;
    recall = 0;
    score = 0;
    
    %Para el tamaño de las máscaras, comparamos pixel a pixel los valores
    %binarizados de ambas y mediante ello establecemos los distintos
    %parámetros: score, precision, recall
    
    [lx,ly] = size(newmask);
    for i = 1:lx
        for j = 1:ly
            if( (newmask(i,j) == 0) && (idealmask(i,j) == 0))
                true_positive = true_positive +1;
            elseif(newmask(i,j) == 0 && idealmask(i,j) == 1)
                false_positive = false_positive +1;
            elseif(newmask(i,j) == 1 && idealmask(i,j) == 0)
                false_negative = false_negative +1;
            elseif(newmask(i,j) == 1 && idealmask(i,j) == 1)
                true_negative = true_negative +1;
            end
        end
    end
    
    true_samples = true_positive+false_negative;
    positive_samples = true_positive+false_positive;
    false_samples = false_positive+true_negative;
    negative_samples = false_negative+true_negative;
    image_size1 = true_samples + false_samples;
    image_size2 = positive_samples + negative_samples;
   
    precision = true_positive/positive_samples;
    recall = true_positive/true_samples;
    score = 2*((precision*recall)/(precision+recall))*100;
end