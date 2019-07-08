function [Y_pre Y_REC para]=multi_regress(Y1,X1,X2,S,time1,cut)

[N1,M1]=size(Y1);
year(:,1)=floor(time1(:,1));
month(:,1)=round((time1(:,1)-year(:,1))*12+0.5);
Y2=Y1(1:cut,:);
XX1=X1(1:cut,:);
XX2=X2(1:cut,:);
[N,M]=size(Y2);
mon_sea=zeros(12,M);
t=time1(1:cut,1);
s=S(1:cut,:);
% for k=1:M
for i=1:12;
    n=0;
    for j=1:cut;
    if(month(j,1)==i)
        mon_sea(i,:)=mon_sea(i,:)+s(j,:);
        n=n+1;
    end
    end
    mon_sea(i,:)= mon_sea(i,:)/n;
end
% end
for i=1:M
X=[ones(N,1),XX1(:,i),XX2(:,i)];
Y=Y2(:,i);
para(i,:)=regress(Y,X);
Y_pre(:,i)=para(i,1)+para(i,2)*X1(:,i)+para(i,3)*X2(:,i);
end
for i=1:M
    for j=1:N1
    if(j<=cut)
        Y_REC(j,i)=Y_pre(j,i)+s(j,i);
    else
        for k=1:12
        if (month(j,1)==k)    
        Y_REC(j,i)=Y_pre(j,i)+mon_sea(k,i);
        end
        end
    end
    end
end
end