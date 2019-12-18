clear all;
close all;

path='Validation-Dataset/Masks-Ideal';
visualize='no';
cd(path);
Files=dir();
cd('../..');

groundtruth = zeros(1,length(Files));
predicted = zeros(1,length(Files));
maxscore=0;
bestw=0;
band = [];
desvia = [];

%  for w = 0.5:0.2:2.5
    for i=3:length(Files)
        filename=Files(i).name
        groundtruth(i)=str2double(filename(1));
        predicted(i)=fingercount(filename,path,visualize);
    end
    %histogram(lele)
    compare = [groundtruth;predicted];
    %figure;
    %conf = confusionchart(groundtruth,predicted,'RowSummary','row-normalized','ColumnSummary','column-normalized');
    c=confusionmat(groundtruth,predicted);
    confusion=c(2:6,2:6);
    precision=zeros(1,5);
    recall=zeros(1,5);
    for i = 1:5
        precision(i)=confusion(i,i)/sum(confusion(:,i));
        recall(i)=confusion(i,i)/sum(confusion(i,:));
    end
    mprecision=mean(precision);
    mrecall=mean(recall);
    fscore=(2*mprecision*mrecall)/(mprecision+mrecall); 
    
%     if fscore > maxscore
%         maxscore=fscore;
%         bestw=w;
%     end
% end