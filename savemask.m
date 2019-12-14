function savemask(mask,filename)
    cd('Training-Dataset/Masks');
    imwrite(mask,horzcat(filename,'.bmp'),'bmp');
    cd('../../');
end


