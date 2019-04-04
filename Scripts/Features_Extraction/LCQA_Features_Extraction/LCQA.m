function Parameter=LCQA(y,fs)
if fs ~= 16000
    y= resample(y,16000,fs);
    fs = 16000;
end
windowSize = .020*fs;
w = hanning(windowSize,'periodic');
y = enframe(y,w,windowSize);
y = y';
y( all(~y,2), : ) = [];
y( :, all(~y,1)) = [];
%% finding LCQA features start here
[a,g] = lpc(y,18);
a(any(isnan(a),2),:) = [];
signalVar = var(y);
siz = min(length(signalVar),length(g));
g = g(1:siz);
signalVar = signalVar(1:siz);
SFM = g'./signalVar; %SFM=Variance of Excitation/Variance of Signal
%% LPC to LSF
f = zeros(18,size(a,1));
for k = 1: size(a,1)
    f(:,k) = poly2lsf(a(k,:));
end
%% IHM Weights
W = zeros(size(f,1),size(f,1),size(f,2));
for k = 1:size(f,2)
    W(1,1,k) = (1/f(1,k))+(1/(f(2,k)-f(1,k)));
    W(length(f(:,k)),length(f(:,k)),k) = 1/(f(length(f(:,k)),k)-f(length(f(:,k))-1,k))+1/(pi-f(length(f(:,k)),k));
    for i = 2:length(f(:,1))-1
        for j = 2:length(f(:,1))-1
            if i == j
                W(i,j,k) = 1/(f(i,k)-f(i-1,k))+1/(f(i+1,k)-f(i,k));
            elseif i ~= j
                W(i,j,k) = 0;
            end
        end
    end
    
end
%%   Spectral Dynamics
SD = zeros(siz,1);
SD(1) = ((f(:,1))')*W(:,:,1)*(f(:,1));
for k = 2:siz
    SD(k) = ((f(:,k)-f(:,k-1))')*W(:,:,k)*(f(:,k)-f(:,k-1));
end

%%   Spectral Centroid
SC = zeros(siz,1);
NUMSC = 0;
DENSC = 0;
for k = 1:siz
    for i = 1:length(f(:,1))
        NUMSC = i* W(i,i,k) + NUMSC;
        DENSC = W(i,i,k) + DENSC;
    end
    SC(k,:) = NUMSC/DENSC;
end

%% Time Derivative of Features
Features = [SFM' g signalVar' SD SC];
DerFeatures = diff(Features,1,1);
%% Statistical Properties
MeanFeatures = mean(Features);
VarFeatures = var(Features);
SkewFeatures = skewness(Features);
KurtFeatures = kurtosis(Features);
MeanDerFeatures = mean(DerFeatures);
VarDerFeatures = var(DerFeatures);
SkewDerFeatures = skewness(DerFeatures);
KurtDerFeatures = kurtosis(DerFeatures);
Parameter = [MeanFeatures VarFeatures SkewFeatures KurtFeatures MeanDerFeatures VarDerFeatures SkewDerFeatures KurtDerFeatures];
%metric=mean(Parameter);
