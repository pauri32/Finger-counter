clear all;
close all;

% Màscara
cd('Training-Dataset/Masks-Ideal');
mask = imcomplement(imread('1_P_hgr1_id02_2.bmp'));
m = double(mask);

% Imatge
cd('../Images');
x = double(imread('1_P_hgr1_id02_2.jpg'));

%Filtrat
for i=1:3
    filt(:,:,i) = x(:,:,i).*(m/255);
end

% Pas de RGB a YCbCr
ycroma = rgb2ycbcr(filt);

cb = ycroma(:,:,2);
cb = cb(:);
cb(cb(:) == median(cb)) = [];

cr = ycroma(:,:,3);
cr = cr(:);
cr(cr(:) == median(cr)) = [];

% Histograma de les components en croma
X = [cb,cr];
H = hist3(X,'Nbins',[25,25],'CDataMode','auto','FaceColor','interp');


% Tria de llindar


% Binarització

