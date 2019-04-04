function [MSE_train,MSE_test]=K_crossval(X,Y,M,K)
% This function implements a cross validation method
% X is a matrix containing the features(columns) for each observation (rows)
% Y observations (subjective scores)
% M an array containing the selected features for the model
% K is the number of sub-datasets
[n,~]=size(X);
MSE_train=0;
MSE_test=0;
indices = crossvalind('Kfold',n,K);
for k = 1:K
    test = (indices == k); 
    train = ~test;
    mdl=fitlm(X(train,M),Y(train));
    Yhat_train=predict(mdl,X(train,M));
    Yhat_test=predict(mdl,X(test,M));
    MSE_train=MSE_train+sum((Y(train)-Yhat_train).^2)/(2*length(Yhat_train));
    MSE_test=MSE_test+sum((Y(test)-Yhat_test).^2)/(2*length(Yhat_test));
end
MSE_train=MSE_train/K;
MSE_test=MSE_test/K;
