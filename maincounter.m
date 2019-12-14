clear all;
close all;

path='Training-Dataset/Masks-Ideal';
visualize='no';
cd(path);
Files=dir();
cd('../..');

groundtruth = zeros(1,length(Files));
predicted = zeros(1,length(Files));
maxscore=0;

for i=3:length(Files)
    filename=Files(i).name;
    groundtruth(i)=str2double(filename(1));
    predicted(i)=fingercount(filename,path,visualize,w);
end
conf = confusionchart(groundtruth,predicted);
points=trace(conf.NormalizedValues);
total=sum(sum(conf.NormalizedValues));
score=(points/total)*100;
% if score > maxscore
%     maxscore = score;
%     bestw = w;
% end
