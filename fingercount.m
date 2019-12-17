function fingercount(imagename,path,visualize,w)
%% OBTENCIÓN DE PARÁMETROS PRINCIPALES

    %cd('C:\Users\piv115\Desktop\manos_PauR_DavidV\Masks-Ideal')
    cd(path);
    im = imread(imagename);
    cd('../..');
    %cd('C:\Users\Patron\Desktop\pruebas\Test-Dataset\Test-Masks');

    %Leemos la imagen y le hacemos un relleno de los posibles huecos que esta
    %pueda contener. Esto limpia bastante las imagenes con peor calidad, lo
    %cual permite que la obtención de los contornos sea mejor. Dado que matlab
    %interpreta un agujero una mancha negra rodeada de puntos blancos, debemos
    %hacer el negativo de nuestra máscara y revertir el proceso después.

    im=imcomplement(im);
    im=imfill(im,'holes');
%     figure;
%     imshow(im);
    im=imcomplement(im);
    %imshow(im)

    %Aplicamos la transformada de la distancia euclidea obteniendo así el punto
    %central de as máscaras. Algunas máscaras situan su punto central en el
    %brazo, cosa que no nos afectará de cara a recorrer el contorno
    %posteriormente.

    dist_tr = bwdist(im,'euclidean');
%     figure;
%     imshow(dist_tr,[])


    [centery,centerx] = find(ismember(dist_tr,max(dist_tr(:))));

    if(length(centery)>1)
        centery=centery(1);
    end
    if(length(centerx)>1)
        centerx=centerx(1);
    end

    %Deefinimos algunos elementos estructurantes que usaremos para limpiar la
    %imagen. 
    %--> se1 eliminará gran parte de las particulas pequeñas de la imagen,
    %aunque recortará dedos ocasionalmente.
    %--> se2 servirá para eliminar contornos que no formen parte de la mano, o
    %que si sean piel, pero no sean relevantes de cara a hacer el recuento de
    %dedos.

    %HAY QUE AJUSTAR EL TAMAÑO DEL STREL SEGÚN EL TAMAÑO DE LA IMAGEN, PROPONGO
    %HACER UNA REDUCCIÓN QUE TOME 480x640 COMO ESTANDAR Y BASADO EN UN LADO
    %HAGA UNA REDUCCIÓN A LA MITAD SI SE DIEZMA, O DOBLE SI SE INTERPOLA
    %se1=strel('square',15);
    se1=strel('disk',12,8);
    se2=strel('square',3);
    se3=strel('square',3);
    im=imclose(im,se1);
    contour=imdilate(im,se2)-im;
%     figure;
%     imshow(contour)

    %% OBTENCIÓN DE CONTORNO DE LA MANO

    [n_rows,n_cols]=size(contour);

    contour=im2bw(contour,0.4); %binariza la imagen y hace que el tipo de dato sea binario

    %Creamos un borde blanco en toda la imagen, para así poder obtener regiones
    %cerradas completamente.

    for i=1:n_rows
        contour(i,n_cols)=1;
        contour(i,1)=1;  
    end

    for i=1:n_cols
        contour(1,i)=1;
        contour(n_rows,i)=1;
    end

    %Aquí rellenamos la mano cuyo centro sabemos que cae en [centery centerx],
    %en algunas ocasiones, el centro se encuentra erroneamente y el se ubica en
    %un píxel de contorno, para evitar esto deplazamos la componente horizontal
    %un píxel hacia la derecha. Cuando rellenemos la mano, eliminamos el resto
    %de figura que no sean la mano propiamente, hacemos un repaso a los
    %agujeros que puedan sobrar y nos quedamos con el contorno final.
    
    if centerx==1
       centerx=2;
    end
    if centerx==n_cols
       centerx=n_cols-1;
    end 
    if centery==1
       centery=2;
    end
    if centery==n_rows
       centery=n_rows-1;
    end 

    f_contour=imfill(contour,[centery centerx]);
%     figure;
%     imshow(f_contour);
%     axis on;
%     hold on;
%     plot(centerx,centery,'ro')
    f_contour=imopen(f_contour,se3);
%     figure;
%     imshow(f_contour);
    f_contour=imfill(f_contour,'holes');
    f_contour=bwmorph(f_contour,'remove');
    

    %% RECORRIDO DEL CONTORNO

    %Aquí lo que se pretende hacer es situarse en un punto arbitrario como el
    %centro que obtenemos en la transformada de la distancia, y ubicar un punto
    %blanco cualquiera, pues sabemos que ese punto es parte del contorno
    %seguro. 

    true=1;
    false=0;
    found=false;
    ini_x=0;
    ini_y=0;
    %PREALLOCATION DE 'BOUNDS'?

    for i=1:n_rows
        for j=1:n_cols
            if f_contour(i,j)==1 && found==false
                found=true;
                ini_y=i;
                ini_x=j;
                break;
            end
        end
        if found==true
            break;
        end
    end

    bounds=bwtraceboundary(f_contour,[ini_y ini_x],'NE');
    bounds=cat(2,bounds,zeros(length(bounds),1));

    for i=1:size(bounds)
        bounds(i,3)=pdist([bounds(i,1),bounds(i,2);centery,centerx],'euclidean');
    end

    dist=bounds(1:end,3);
%     minstart=smoothdist;
    mindistpos = find(dist==min(dist));
    ini2min=dist(1:mindistpos(1))';
    min2fin=dist((mindistpos(1)+1):length(dist))';
    minstart=horzcat(min2fin,ini2min);
    smoothdist=medfilt1(smooth(minstart,50),150);
%    smoothdist=smooth(median(minstart,100),50);
    
    local_max=islocalmax(smoothdist);
    local_min=islocalmin(smoothdist);
    local_min(1)=1;
    local_min(length(smoothdist))=1;
 
    th = 1.7*std(smoothdist);
    for i = 1:length(local_max)
         if smoothdist(i) < th
             local_max(i) = 0;
         end
    end
    
    maxima=find(local_max==1);
    minima=find(local_min==1);
    possible_arm = zeros(1,length(maxima));
    
    for i = 1:length(maxima)
        bw = min(abs(maxima(i)-minima));
        possible_arm(i) = bw;
    end
    maxbw = max(possible_arm);
    desv=std(possible_arm);
    
    if(strcmp('yes',visualize) == 1)
        figure();
        hold on;
        title('Finger detector')
        %plot(dist);
%         olakase = smooth(median(minstart,100),50);
        plot(smoothdist);
        hold on;
        stem(300*local_max,'X');
        stem(300*local_min,'O');
        hline = refline([0 th]);
        hline.Color = 'r';
        hold off;
    end

    numfingers = length(maxima);
    if maxbw > 200
        numfingers = numfingers-1;
    end
    
%     if max(smoothdist) > 1.5*mean(smoothdist)
%         numfingers=numfingers-1;
%     end
        
    if numfingers > 5
        numfingers = 5;
    elseif numfingers < 1
        numfingers = 1;
    end
end