function [Parameter] = Extract_LCQA()
%This function is used to calculate the LCQA features of speech wav files
%that are stored on the PC and their names are stored in an Excel sheet.
%Parameter is an m*40 matrix whhere m is the number of speech samples and
%40 is the number of LCQA features per file
d=uigetdir('Select Recordings Folder');
[NFileName,NPathName] = uigetfile('*.xlsx','Select Excel file');
e=strcat(NPathName,NFileName);
[~,txt]=xlsread(e,'A1:A113');
Parameter=zeros(size(txt,1),40);
for k=1:size(txt,1)
    [y,fs]=audioread(strcat(d,'\',txt{k}));
    Parameter(k,:)=LCQA(y, fs);
end
