%Forward stepwise regression based on the highest R2 
function M=Fstepwise(X,Y)
[~,p]=size(X);
M=[];
F=[];
for k=1:p
    m=1;
    while(m<=p)
        if(~ismember(m,M)) 
            mdl=fitlm([F X(:,m)],Y);
            R(m)=mdl.Rsquared.Ordinary;
        else
            R(m)=0; %to make sure the max will not be 0...
        end
        m=m+1;
    end
    [~,M(k)]=max(R);
    F=[F X(:,M(k))];
    if(max(R)>1)
        break;
    end
end