function bounds=fingercount2(imagename,path,visualize,w)
%% OBTENCI�N DE PAR�METROS PRINCIPALES

    %cd('C:\Users\piv115\Desktop\manos_PauR_DavidV\Masks-Ideal')
    cd(path);
    im = imread(imagename);
    cd('../..');
    %cd('C:\Users\Patron\Desktop\pruebas\Test-Dataset\Test-Masks');

    %Leemos la imagen y le hacemos un relleno de los posibles huecos que esta
    %pueda contener. Esto limpia bastante las imagenes con peor calidad, lo
    %cual permite que la obtenci�n de los contornos sea mejor. Dado que matlab
    %interpreta un agujero una mancha negra rodeada de puntos blancos, debemos
    %hacer el negativo de nuestra m�scara y revertir el proceso despu�s.

    im=imcomplement(im);
    im=imfill(im,'holes');
    im=imcomplement(im);
    %imshow(im)

    %Aplicamos la transformada de la distancia euclidea obteniendo as� el punto
    %central de as m�scaras. Algunas m�scaras situan su punto central en el
    %brazo, cosa que no nos afectar� de cara a recorrer el contorno
    %posteriormente.

    dist_tr = bwdist(im,'euclidean');
    %figure;
    %imshow(dist_tr,[])


    [centery,centerx] = find(ismember(dist_tr,max(dist_tr(:))));

    if(length(centery)>1)
        centery=centery(1);
    end
    if(length(centerx)>1)
        centerx=centerx(1);
    end

    %Deefinimos algunos elementos estructurantes que usaremos para limpiar la
    %imagen. 
    %--> se1 eliminar� gran parte de las particulas peque�as de la imagen,
    %aunque recortar� dedos ocasionalmente.
    %--> se2 servir� para eliminar contornos que no formen parte de la mano, o
    %que si sean piel, pero no sean relevantes de cara a hacer el recuento de
    %dedos.

    %HAY QUE AJUSTAR EL TAMA�O DEL STREL SEG�N EL TAMA�O DE LA IMAGEN, PROPONGO
    %HACER UNA REDUCCI�N QUE TOME 480x640 COMO ESTANDAR Y BASADO EN UN LADO
    %HAGA UNA REDUCCI�N A LA MITAD SI SE DIEZMA, O DOBLE SI SE INTERPOLA
    %se1=strel('square',15);
    se1=strel('disk',12,8);
    se2=strel('square',3);
    se3=strel('square',3);
    im=imclose(im,se1);
    contour=imdilate(im,se2)-im;
    %figure;
    %imshow(contour)

    %% OBTENCI�N DE CONTORNO DE LA MANO

    [n_rows,n_cols]=size(contour);

    contour=im2bw(contour,0.4); %binariza la imagen y hace que el tipo de dato sea binario

    %Creamos un borde blanco en toda la imagen, para as� poder obtener regiones
    %cerradas completamente.

    for i=1:n_rows
        contour(i,n_cols)=1;
        contour(i,1)=1;  
    end

    for i=1:n_cols
        contour(1,i)=1;
        contour(n_rows,i)=1;
    end

    %Aqu� rellenamos la mano cuyo centro sabemos que cae en [centery centerx],
    %en algunas ocasiones, el centro se encuentra erroneamente y el se ubica en
    %un p�xel de contorno, para evitar esto deplazamos la componente horizontal
    %un p�xel hacia la derecha. Cuando rellenemos la mano, eliminamos el resto
    %de figura que no sean la mano propiamente, hacemos un repaso a los
    %agujeros que puedan sobrar y nos quedamos con el contorno final.

    f_contour=imfill(contour,[centery centerx+1]);
    f_contour=imopen(f_contour,se3);
    f_contour=imfill(f_contour,'holes');
    f_contour=double(bwmorph(f_contour,'remove')); 
    
    for i=1:n_rows
      for j=1:n_cols
          if f_contour(i,j) == 1
            f_contour(i,j) = double(sqrt((i-centerx)^2+(j-centery)^2));
          end
      end
    end
    
    maxima = zeros(n_rows,n_cols);
    th = 0.2;
    for i=1:n_rows
      for j=1:n_cols
          if f_contour(i,j) > th && f_contour(i,j) ~= 0
            maxima(i,j) = 0;
          end
      end
    end
    
    maxima = imregionalmax(f_contour);
    maximposx = [];
    maximposy = [];
    for i=1:n_rows
      for j=1:n_cols
          if maxima(i,j)==1
              maximposx = vertcat(maximposx,i);
              maximposy = vertcat(maximposy,j);
          end
      end
    end
    
    figure;
    imshow(f_contour);
    for n = 1:length(maximposx)
        axis on
        hold on;
        plot(maximposy(n),maximposx(n), 'ro', 'MarkerSize', 5);
    end