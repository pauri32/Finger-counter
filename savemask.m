function savemask(mask,filename)
    cd('Validation-Dataset/Masks');
    imwrite(mask,horzcat(filename,'.bmp'),'bmp');
    cd('../../');
end