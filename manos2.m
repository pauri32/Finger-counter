clc;
clear all;
close all;

%cd('C:\Users\Patron\Desktop\2020 Q1\PIV\LAB\Programación\Training-Dataset\Images');
%addpath 'C:\Users\Patron\Desktop\2020 Q1\PIV\LAB\Programación'

cd('Training-Dataset/Images');

Files=dir();
max_len=0;
hb = zeros(255);
hr = zeros(255);

for k=3:length(Files)
    filename=erase(Files(k).name,".jpg");
    cd('../../')
    H = gethist(filename);
    if length(X)>max_len
       max_len=length(X);
    end 
end


% bluebins = zeros(1,3*max_len);
% redbins = zeros(1,3*max_len);

for i=3:length(Files)
   filename=erase(Files(i).name,".jpg");
   cd('../../');
   X=gethist(filename);
   for j=1:length(X)
       bluebins = horzcat(bluebins,X(1));
       redbins = horzcat(redbins,X(2));
   end
end
%no podemos especificar edges y bins a la vez
%1:255 o 1:256?
figure;
ajaja = hist(totalBins(:,1),'Edges',1:255);
hist3(totalBins,'Edges',{(1:255),(1:255)},'CDataMode','auto','FaceColor','interp');


saveblue = [];
savered = [];

% lindar = 70;
% for i = 1:255
%     for j = 1:255
%         if H(i,j) > lindar
%             saveblue = horzcat(saveblue,i);
%             savered = horzcat(savered,j);
%         end
%     end
% end

cd('../../Validation-Dataset/Images');
ima = imread('1_P_hgr1_id06_1.jpg');
ycroma = double(rgb2ycbcr(ima));
newcb = ycroma(:,:,2);
newcr = ycroma(:,:,3);
[lx,ly,lz] = size(ima);

mascara = zeros(lx,ly);

for i = 1:lx
    for j = 1:ly
        if find(saveblue == newcb(i,j))
            if find(savered == newcr(i,j))
                mascara(i,j) = 0;
            else
                mascara(i,j) = 1;
            end
        end
     end
end
cd('../../');

savemask(mascara, '1_P_hgr1_id06_1');
score = fscore('1_P_hgr1_id06_1');

% cd('../../Validation-Dataset/Images');
% ima = imread('1_P_hgr1_id06_1.jpg');
% imacroma = rgb2ycbcr(ima);
% 
% [max_num,max_idx] = max(H(:));
% [maxred,maxblue]=ind2sub(size(H),max_idx);
% desvblue = 7;
% fblue = fspecial('gaussian',maxblue,desvblue);
% newblue = filter2(fblue,double(imacroma(:,:,2)));
% 
% 
% desvred = 7;
% fred = fspecial('gaussian',maxred,desvred);
% newred = filter2(fred,double(imacroma(:,:,2)));
% 
% newimacroma(:,:,1) = imacroma(:,:,1);
% newimacroma(:,:,2) = newblue;
% newimacroma(:,:,3) = newred;
% 
% newima = ycbcr2rgb(newimacroma);
% 
% imshow(newima)
% 
