%"Predicting the intelligibility of reverberant speech for cochlear implant
% listeners with a non-intrusive intelligibility measure"
% Authors:Fei Chen, Oldooz Hazrati, Philipos C. Loizou, 2012, 
%
% This software may be used for non-commercial academic and research purposes only.
% Any other use of the software, including commercial release, lease, or redistribution requires the developers' permission, 
% contact: feichen1@hku.hk, hazrati@utdallas.edu for details.
% All rights reserved.
% The University of Texas at Dallas
%function [ModA, ModA_k]= ModA_nonintrusive(wavefile,  F_enve, channels)
function [ModA, ModA_k,ModA_k_n]= ModA_nonintrusive(y, rate,  F_enve, channels)
% wavefile: noise-corrupted file

global M_CHANNELS
global F_SIGNAL

%[y,rate]= wavread(wavefile);

y=y*0.8/max(abs(y)); % limit peak amplitude to [-0.8, 0.8]

%%
F_SIGNAL    =   rate;           % 25000
F_ENVELOPE  =   F_enve;

%   DEFINE BAND EDGES
M_CHANNELS  =   channels;
BAND	    =	Band;

%   GENERATE BANDPASS FILTERS
for a = 1:M_CHANNELS,
    [B_bp A_bp]         =	butter( 4 , [BAND(a) BAND(a+1)]*(2/F_SIGNAL) );
    Y_BANDS( : , a )    =	filter( B_bp , A_bp , y );
    %fprintf('%d: %f - %f\n',a,BAND(a),BAND(a+1));
end

%   CALCULATE HILBERT ENVELOPES
analytic_y	    =	hilbert( Y_BANDS );
Y               =	abs( analytic_y );
Y               =   resample( Y , F_ENVELOPE , F_SIGNAL );
Y_mean=mean(Y);

[row, col]=size(Y);
LL=row;

%% Compute MTF
s=2.^(1/3);
f0=[0.5 0.5*s 0.5*s*s ...
    1.0 1.0*s 1.0*s*s ...
    2.0 2.0*s 2.0*s*s ...
    4.0 4.0*s 4.0*s*s ...
    8.0 8.0*s 8.0*s*s ...
    16  16*s  16*s*s ...
    32  32*s  32*s*s ...
    64  64*s  64*s*s];

f0=f0(find(f0<F_enve/2));
Df0=diff(f0);

Y_mtf=zeros(length(f0),channels);   Y_mtf_dm=zeros(length(f0),channels);
%%
for ii=1:channels
    sig_bp=Y(:, ii)-mean(Y(:, ii));
%     sig_bp=Y(:, ii);
    for jj = 1:length(f0)
        [B_bp,A_bp] = oct3dsgn(f0(jj),F_enve,3);
        ttt=filter(B_bp, A_bp, sig_bp);
        Y_mtf(jj, ii)=norm(ttt-mean(ttt), 2)/sqrt(LL);
%         Y_mtf(jj, ii)=norm(ttt, 2)/sqrt(LL);
        Y_mtf_dm(jj, ii)=Y_mtf(jj, ii)/Y_mean(ii);
    end
end
Y=Y_mtf_dm; % Use the normalized
                
%% compute the area
ModA_k=[];
for kk=1:channels % area based
    % do summation
    bbb=sum(Y(:,kk)); % bbb=mean(Y(:,kk));        
    ModA_k=[ModA_k bbb];    
end

weight1=[2.0117 2.3190 1.8778 2.6141];   % normalization factors when N=4,fcut=10Hz, F_env=20Hz;
%weight1=    [3.0731    4.2880    4.6798    4.1494    4.9729    3.7481    3.3029    3.4529]; %New Normalization Factors in My Recordings
ModA_k_n=ModA_k./weight1;
ModA(1,1)=mean(ModA_k_n);

function BAND = Band
    global M_CHANNELS
    BAND        =   Get_Band(M_CHANNELS);
                 
%------------------------------------------------------------------------------
function BAND = Get_Band(M)
    global F_SIGNAL
    A                   =   165;
    a                   =   2.1;
    K                   =   1;
    L                   =   35;
    CF = 300; 
    x_100     =   (L/a)*log10(CF/A + K);

    if F_SIGNAL==25000
        CF = 12000;  % for rate=25000
    elseif F_SIGNAL==16000
        CF = 7600;
    elseif F_SIGNAL==8000
        CF = 3400;
    end
    x_8000   =   (L/a)*log10(CF/A + K);

    LX                  =   x_8000 - x_100;
    x_step              =   LX / M;
    x                   =   [x_100:x_step:x_8000];
    if length(x) == M, x(M+1) = x_8000; end
    BAND                =   A*(10.^(a*x/L) - K);
