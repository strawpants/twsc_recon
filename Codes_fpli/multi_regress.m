function [Y_pre]=multi_regress(Y11,X11,cut,L1,L2)
% INPUTS:
%   Y1(N,M)       : Matrix of outputs where N is time and M is number of points.
%    
%   X1(N,T,M)     : Matrix of intput 1 where N is time, T is channel, and M is number of points.
%           
%   L1     :Longth of train data
%
%   L2     :Longth of prediction
%
%   Cut    : Truncation of Z1, You can use Z(Cut-L1+1:Cut,1,POINTS) to train the 
%            ARX model and use Z(Cut+1:Cut+L2,1,POINTS) to test the prediction.
%
%
% OUTPUTS:
%   Y_pre (N,M)    : Prediction of Y1
%
%
% AUTHORS:
%   Fupeng Li
%   SGG,Wuhan University,China
%   Email:fpli@whu.edu.cn
[N2,M2,W2]=size(X11);
Y1=Y11(cut-L1+1:cut+L2,:);
[N1,M1]=size(Y1);
Y2=Y1(1:L1,:);
[N,M]=size(Y2);
Y_pre=zeros(N1,M);
for i=1:M
for j=1:M2
X1(:,j)=X11(cut-L1+1:cut+L2,j,i);
end
XX1=X1(1:L1,:);
X=[ones(N,1),XX1];
Y=Y2(:,i);
para(i,:)=regress(Y,X);
X111=[ones(N1,1),X1];
for j=1:M2+1
Y_pre(:,i)=Y_pre(:,i)+para(i,j)*X111(:,j);
end
end
end