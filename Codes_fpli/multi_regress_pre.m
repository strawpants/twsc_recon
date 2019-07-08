function [Y_pre]=multi_regress_pre(Y11,X11)
% INPUTS:
%   Y1(N,M)       : Matrix of outputs where N is time and M is number of points.
%    
%   X1(N1,T,M)     : Matrix of intput 1 where N1 is time, T is channel, and M is number of points.
%           
% OUTPUTS:
%   Y_pre (N1,M)    : Prediction of Y1
%
% AUTHORS:
%   Fupeng Li
%   SGG,Wuhan University,China
%   Email:fpli@whu.edu.cn
[N1,M1,W1]=size(X11);
[N,M]=size(Y11);
Y_pre=zeros(N1,M);
for i=1:M
for j=1:M1
X1(:,j)=X11(:,j,i);
end
XX1=X1(1:N,:);
X=[ones(N,1),XX1];
Y=Y11(:,i);
para(i,:)=regress(Y,X);
X111=[ones(N1,1),X11];
for j=1:M1+1
Y_pre(:,i)=Y_pre(:,i)+para(i,j)*X111(:,j);
end
end
end