function [ceps] = ...
		gfcc(input, samplingRate, frameRate,fcoefs)
%This function calculates 30 GFCC featues for a speech signal.
%Inputs are input: the raw speech signal, samplingrate : 16 kHz,
%framerate,fcoefs: ERB filterbank.
%The output is 30 features vector where 30 is the number of GFCC features.
global gfccDCTMatrix gfccFilterWeights

[r, c] = size(input);
if (r > c) 
	input=input';
end

 fftSize = 512;  % This the number of fft bin points.
cepstralCoefficients = 30; %Number of GFCC cepstral coefficients.
windowSize = 256;		% Standard says 400, but 256 makes more sense

if (nargin < 2) samplingRate = 16000; end;
if (nargin < 3) frameRate = 100; end;


totalFilters = 128; % Number of ERB filters.

t=ERBFilterBank([1 zeros(1,511)],fcoefs);
gfccFilterWeights=abs(fft(t));
    
hamWindow = 0.54 - 0.46*cos(2*pi*(0:windowSize-1)/windowSize);

if 0					% Window it like ComplexSpectrum
	windowStep = samplingRate/frameRate;
	a = .54;
	b = -.46;
	wr = sqrt(windowStep/windowSize);
	phi = pi/windowSize;
	hamWindow = 2*wr/sqrt(4*a*a+2*b*b)* ...
		(a + b*cos(2*pi*(0:windowSize-1)/windowSize + phi));
end

% Figure out Discrete Cosine Transform.  We want a matrix
% dct(i,j) which is totalFilters x cepstralCoefficients in size.
% The i,j component is given by 
%                cos( i * (j+0.5)/totalFilters pi )
% where we have assumed that i and j start at 0.
gfccDCTMatrix = 1/sqrt(totalFilters/2)*cos((0:(cepstralCoefficients-1))' * ...
				(2*(0:(totalFilters-1))+1) * pi/(2*totalFilters));
gfccDCTMatrix(1,:) = gfccDCTMatrix(1,:) * sqrt(2)/2;



% Filter the input with the preemphasis filter.  Also figure how
% many columns of data we will end up with.
if 1
	preEmphasized = filter([1 -.97], 1, input);
else
	preEmphasized = input;
end
windowStep = samplingRate/frameRate;
cols = fix((length(input)-windowSize)/windowStep);

% Allocate all the space we need for the output arrays.
ceps = zeros(cepstralCoefficients, cols);


% Ok, now let's do the processing.  For each chunk of data:
%    * Window the data with a hamming window,
%    * Shift it into FFT order,
%    * Find the magnitude of the fft,
%    * Convert the fft data into filter bank outputs,
%    * Find the log base 10,
%    * Find the cosine transform to reduce dimensionality.
for start=0:cols-1
    first = start*windowStep + 1;
    last = first + windowSize-1;
    
   fftData = zeros(1,fftSize);
    fftData(1:windowSize) = preEmphasized(first:last).*hamWindow;
    fftMag = abs(fft(fftData));
    earMag = log10(gfccFilterWeights * fftMag');

    ceps(:,start+1) = gfccDCTMatrix * earMag;

end



