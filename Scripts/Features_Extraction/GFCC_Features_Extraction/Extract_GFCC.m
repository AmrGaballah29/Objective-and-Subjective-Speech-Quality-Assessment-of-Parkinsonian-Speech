function [Parameter] = Extract_GFCC()
%This script is used to extract GFCC features from a group of recordings.
%This function returns Parameter: an  m*60 feature matrix where m is the
%number of audio samples and 60 is the number of GFCC features from one
%recording.
d=uigetdir('Select Recordings Folder'); %To get the location of the audiofiles
%The files' names has to be stored in an excel sheet.
[NFileName,NPathName] = uigetfile('*.xlsx','Select Excel file');%Get the excel sheet location
e=strcat(NPathName,NFileName);
[~,txt]=xlsread(e,'A1:A113');%Read the wav files' names from the excel sheet
fcoefs=MakeERBFilters(16000,128,50);%calculate the ERB filter coefficients.
for k=1:size(txt,1)
    [y,fs]=audioread(strcat(d,'\',txt{k})); %Get GFCC coefficients.
    Parameter(k,:)=GFCC2(y, fs,fcoefs);
end
