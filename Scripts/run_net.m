function [net]=run_net(X,Y,neurons1,neurons2)
%This is a function to generate a neural network to predict the quality of
%Parkinsonian speech.
%The inputs are X: the training features matrix, Y: the training labels,
%neurons1: number of neurons in the first hidden layer, and neurons2;
%number of neurons in the second hidden layer.
if (nargin < 3)
    neurons1=25;
end
if (nargin < 4)
    neurons2=12;
end

% Define the neural network and the optimizer.
net = fitnet([neurons1 neurons2],'trainlm');

% Set up Division of Data for Training, Validation, Testing
net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 15/100;

%Regularization parameter
net.performParam.regularization = 0.01;

for i=1:100
    [net,~] = train(net,X',Y');
end

%Yhat=net(X(:,M(1:k))')';