clear all;
close all;

path='Training-Dataset/Masks';
visualize='no';
cd(path);
Files=dir();

for i=4:length(Files)
    filename=Files(i).name;
    im=imread(filename);
    
    dist_tr = bwdist(im,'euclidean');
    [centery,centerx] = find(ismember(dist_tr,max(dist_tr(:))));
    
    contour = imgradient(im,'roberts');
    se1=strel('disk',12,8);
    se2=strel('square',3);
    contour=imclose(contour,se1);
    contour=imdilate(im,se2)-im;
    imshow(contour)
end