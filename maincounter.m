clear all;
close all;

path='Training-Dataset/Masks-Ideal';
visualize='yes';
cd(path);
Files=dir();
cd('../..');

groundtruth = zeros(1,length(Files));
predicted = zeros(1,length(Files));
maxscore=0;
bestw=0;
band = [];
desvia = [];

%  for w = 1:1
    for i=4:length(Files)
        filename=Files(i).name
        groundtruth(i)=str2double(filename(1));
        fingercount(filename,path,visualize,9);
%         band = horzcat(band,bw);
%         desvia = horzcat(desvia,desv);
    end
%     histogram(lele)
    compare = [groundtruth;predicted];
%     conf = confusionchart(groundtruth,predicted,'RowSummary','row-normalized','ColumnSummary','column-normalized');
%     points=trace(conf.NormalizedValues);
%     total=sum(sum(conf.NormalizedValues));
%     score = (points/total)*100;
%     if score > maxscore
%         maxscore=score;
%         bestw=w;
%     end
% end