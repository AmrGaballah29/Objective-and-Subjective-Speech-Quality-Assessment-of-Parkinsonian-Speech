function [MSE_train,MSE_test,M] = Select_Features(X,Y)
%This function is used to reduce the number of the features matrix to avoid
%overfitting.
%Inputs are: X: the full training features' matrix, Y: training labels
%Outputs: MSE_Train: the training mean square error, MSE_test: the test
%mean square error, M: a vector cotains the indices of the input features
%arranged in an descending order according to their correlation with the
%training labels.
M=Fstepwise(X,Y);
p=length(M);

N=100;
MSE_train=zeros(1,p);
MSE_test=zeros(1,p);
for k=1:p
    for n=1:N
        
        [e1,e2]=K_crossval(X,Y,M(1:k),10);
        MSE_train(k)=MSE_train(k)+e1/N;
        MSE_test(k)=MSE_test(k)+e2/N;
    end
end

figure(1)
plot(1:p,MSE_train,'b')
hold on
plot(1:p,MSE_test,'r')
hold on

