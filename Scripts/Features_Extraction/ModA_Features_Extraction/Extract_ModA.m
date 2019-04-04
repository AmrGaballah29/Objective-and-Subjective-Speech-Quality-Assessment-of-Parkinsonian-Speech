function [ModA] = Extract_ModA()
%This function is used to calculate the ModA of speech wav files
%that are stored on the PC and their names are stored in an Excel sheet.
%ModA is an m*1  vector whhere m is the number of speech samples 
d=uigetdir('Select Recordings Folder');
[NFileName,NPathName] = uigetfile('*.xlsx','Select Excel file');
e=strcat(NPathName,NFileName);
[~,txt]=xlsread(e,'Sheet1','A1:A113');
ModA=zeros(size(txt,1),1);
for k=1:size(txt,1)
    [y,fs]=audioread(strcat(d,'\',txt{k}));
    y=resample(y,16000,fs);
    [ModA(k),~,~]=ModA_nonintrusive(y, 16000,20,4);
end
