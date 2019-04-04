function Parameter=GFCC2(y,fs,fcoefs)
%This function is used to resample the audio files to 16 kHZ sampling
%frequency, calculate the dynamic features, and return Parameter: a vector
%of 60 GFCC features.
%The inputs are y: the raw speech signal, fs: the audio sampling frequency,
%and fcoefs: the ERB filterbank.
if fs ~= 16000
    y= resample(y,16000,fs);
    fs = 16000;
end
ceps=gfcc(y,fs,100,fcoefs);
%ceps=gfcce(y,fs,100,fcoefs);
for i=3:size(ceps,2)-2
    temp=zeros(size(ceps,1),1);
    for j=1:2
        z(:,i)=temp+j*(ceps(:,i+j)-ceps(:,i-j))/(2*j^2);
        temp=z(:,i);
    end
end
c=[ceps;z,zeros(size(ceps,1),(size(ceps,2)-size(z,2)))];
Parameter=zeros(size(c,1),1);
for i=1:size(c,1)
    Parameter(i)=mean(c(i,:));
end