 function [Param,Calib,ARXResi,ARXRMS,ARXPred,ARXPreResi,ARXPreRMS] = ARX_TEST (X1,Z1,Orders,kq,Cut,L1,L2)

% INPUTS:
%   X1 (TIME, CHANNELS, POINTS) : Matrix of several channels of inputs.
%    
%   Z1 (TIME, 1, POINTS)        : Matrix of one channel of outputs.
%   
%   Orders : Order of the ARX model(na,nb).
%
%   kq     : Time steps of inputs (kq(1),kq(2)...depends on the channels of
%            inputs).
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
%   Param (ORDER, POINTS)    : ARX parameters
%
%   Calib (TIME, POINTS)     : ARX Calibration
%
%   ARXResi (TIME, POINTS)   : ARX residuals
%
%   ARXRMS (POINTS, RMS)     : RMS of ARX residual errors
%
%   ARXPred (TIME, POINTS)   : Predictand
%
%   ARXPreResi(TIME, POINTS) : Residuals of predictand
%
%   ARXPreRMS                : RMS of predictand
%
% AUTHORS:
%   Fupeng Li
%   SGG,Wuhan University,China
%   First created in Nov.17, 2018.  
%   Email:fpli@whu.edu.cn
%
% Reference:
%   Ehsan Forootan, J?rgen Kusche, Ins Loth, et al. Multivariate Prediction of 
%   Total Water Storage Changes Over West Africa from Multi-Satellite Data[J]. 
%   Surveys in Geophysics, 2014, 35(4):913-940.

% Set parameters
na=Orders(1);
nb=Orders(2);
X=X1(Cut-L1+1:Cut+L2,:,:);
Y=Z1(Cut-L1+1:Cut,1,:);
Z=Z1(Cut-L1+1:Cut+L2,:,:);
[tz mz nz] = size(Z);
[ty my ny] = size(Y);
[tx m  nx] = size(X);
if (nx~=nz)
    error('the points of inputs and outputs are unmatched')
end
if (mz~=1)
    error('the number of outputs column must be 1')
end
n=nx;
t=ty;
for i=1:n
c(i)=max(na,nb)+max(kq(:,i))+1; % starting point
end
%% ================Initialization==========================================
Param         = zeros(na+nb*m,n);
Calib         = zeros(t,1,n);
ARXResi       = zeros(t,1,n);
ARXRMS        = zeros(n,1);
D             = zeros(na+nb*m,1);
ARXPred       = zeros(tx,n);
ARXPreResi    = zeros(tz-ty,n);
ARXPreRMS     = zeros(n,1);
%%ARX model begain in different points
for u=1:n
Aa            = zeros(t-c(u)+1,na,n);
Ab            = zeros(t-c(u)+1,nb*m,n);
%% =================Creat the coefficient matrix A=========================
    for i=1:na
        Aa(:,i,u)=Y(c(u)-i:t-i,1,u);
    end
    for v=1:m
    for i=1:nb
        Ab(:,i+(v-1)*nb,u)=X(c(u)-kq(v,u)-i+1:t-kq(v,u)-i+1,v,u);
    end
    end
     A=[Aa(:,:,u) Ab(:,:,u)];

%% =================Parameter and ARX RMS estimation=======================  
     B=Y(c(u):t,1,u);%%Define B vector
     Param(:,u)=pinv(A)*B;%Parameter estimation
     Calib(c(u):t,1,u) = A*Param(:,u);%Predict the known values
     ARXResi(:,1,u) = Calib(:,1,u) - Y(:,1,u);%Residuals
     ARXRMS(u,1)=sqrt(1/t*sum(ARXResi(:,1,u).^2));%RMS 

%% ================Predictand and its RMS estimation======================= 

  ARXPred(1:ty,u)=Y(:,1,u);
  for k=t+1:tx
%%-------Creat the data matrix D-------------------------------------------
    for i=1:na
        D(i,1)=ARXPred(k-i,u);
    end
    for i=1:m
      for j=1:nb
        D(na+nb*(i-1)+j,1)=X(k-kq(i,u)-j+1,i,u);
      end
    end
%%-------Predict the unknown values----------------------------------------
     ARXPred(k,u)=Param(:,u)'*D;
  end
     ARXPred(1:ty,u)=Calib(:,1,u);
%%-------Predictand RMS estimation-----------------------------------------
     ARXPreResi=ARXPred(ty+1:end,u) - Z(ty+1:end,1,u);
     ARXPreRMS(u,1)=rms(ARXPred(ty+1:end,u) - Z(ty+1:end,1,u));
%%=========================================================================
end

end
