clear all;
close all;
% M�scara
    filename = '1_P_hgr1_id01_2';
    cd('Training-Dataset/Masks-Ideal');
    %cd('C:\Users\piv115\Desktop\Programaci�n\Training-Dataset\Masks-Ideal');
    
    mask = imcomplement(imread(strcat(filename,'.bmp')));
    m = double(mask);

    % Imatge
    %cd('../Images');
    cd('../Images');
    x = double(imread(strcat(filename,'.jpg')));

    %Filtrat
    for i=1:3
        filt(:,:,i) = x(:,:,i).*(m/255);
    end

    % Pas de RGB a YCbCr
    ycroma = rgb2ycbcr(filt);
    %figure;
    %imshow(ycroma)

    %Eliminem el negre de l'histograma
    cb = ycroma(:,:,2);
    cb = cb(:);
    cb(cb(:) == mode(cb)) = [];

    cr = ycroma(:,:,3);
    cr = cr(:);
    cr(cr(:) == mode(cr)) = [];

    cb = floor(cb.*255);
    cr = floor(cr.*255);


    % Histograma de les components en croma
    X = [cb,cr];
    %figure;
    hist3(X,'Edges',{(1:255),(1:255)},'CDataMode','auto','FaceColor','interp');
