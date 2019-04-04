function [Parameter] = Extract_MFCC()
%This function is used to calculate the MFCC features of speech wav files
%that are stored on the PC and their names are stored in an Excel sheet.
%Parameter is an m*26 matrix whhere m is the number of speech samples and
%40 is the number of MFCC features per file
d=uigetdir('Select Recordings Folder');
[NFileName,NPathName] = uigetfile('*.xlsx','Select Excel file');
e=strcat(NPathName,NFileName);
[~,txt]=xlsread(e,'A2:A667');
for k=1:size(txt,1)
    [y,fs]=audioread(strcat(d,'\',txt{k}));
    Parameter(k,:)=MFCC2(y, fs);
end
