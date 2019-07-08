 function [ANNPred]=ANN_TEST(X1,Z1,N,Cut,L1,L2)

% INPUTS:
%   X1 (TIME, CHANNELS, POINTS) : Matrix of several channels of inputs.
%    
%   Z1 (TIME, 1, POINTS)        : Matrix of one channel of outputs.
%   
%   N      : Hidden layer.
%
%   L1     :Longth of train data
%
%   L2     :Longth of prediction
%
%   Cut    : Truncation of Z1, You can use Z(Cut-L1+1:Cut,1,POINTS) to train the 
%            ARX model and use Z(Cut+1:Cut+L2,1,POINTS) to test the prediction.
%
% OUTPUTS:
%
%
%   ANNPred (TIME, POINTS)   : Predictand
%
%
% AUTHORS:
%   Fupeng Li
%   SGG,Wuhan University,China
%   First created in Nov.21, 2018.  
%   Email:fpli@whu.edu.cn
%
nodenumber=N;
X=X1(Cut-L1+1:Cut+L2,:,:);
Z=Z1(Cut-L1+1:Cut+L2,:,:);
[tz mz  nz] = size(Z);
[tx mx  nx] = size(X);
if (nx~=nz)
    error('the points of inputs and outputs are unmatched')
end
if (tx~=tz)
    error('the time series of inputs and outputs are unmatched')
end
if (mz~=1)
    error('the number of outputs column must be 1')
end
n=nx;
t=tx;
%% -------------------Initialization---------------------------------------
ANNPred      =    zeros(t,n);
ANNResi      =    zeros(L1,n);
ANNPreResi   =    zeros(t-L1,n);
ANNRMS       =    zeros(n);
ANNPreRMS    =    zeros(n);
ANN_R        =    zeros(n);
ANNPre_R     =    zeros(n);
% disp('    Point     Node_NO.  RMS_train RMS_pred  R_train   R_pred'); 
for i=1:n
%% -----------KS devide data into training set and predicting set----------
x_train=X(1:L1,:,i)';
y_train=Z(1:L1,1,i)';
x_pred=X(L1+1:end,:,i)';
y_pred=Z(L1+1:end,1,i);

%% -------------------data centring ---------------------------------------
[input_train,inputps]=mapminmax(x_train);
[output_train,outputps]=mapminmax(y_train);

%% -------------------BP-ANN predicting outside----------------------------
net=newff(input_train,output_train,[nodenumber]);
net.trainParam.showWindow = false; 
net.trainParam.showCommandLine = false; 
inputWeights           = net.IW{1,1};
inputbias              = net.b{1};
layerWeights           = net.LW{2,1}; 
layerbias              = net.b{2};   
net.trainParam.epochs  = 2000;
net.trainParam.lr      = 0.01;
net.trainParam.goal    = 0.00004;
net=train(net,input_train,output_train);
input_pred=mapminmax('apply',x_pred,inputps);
am=sim(net,input_train);
an=sim(net,input_pred);
BPoutput_train=mapminmax('reverse',am,outputps)';
BPoutput_pred=mapminmax('reverse',an,outputps)';
ANNPred(1:L1,i)=BPoutput_train(:,1);
ANNPred(L1+1:end,i)=BPoutput_pred(:);

%% -------------------error estimation-------------------------------------
% ANNResi(:,i)      =    BPoutput_train-y_train';
% ANNPreResi(:,i)   =    BPoutput_pred-y_pred;
% ANNRMS(i)         =    rms(BPoutput_train-y_train');
% ANNPreRMS(i)      =    rms(BPoutput_pred-y_pred);
% R_trainbpANN      =    corrcoef(BPoutput_train,y_train');
% ANN_R(i)          =    R_trainbpANN(1,2);
% R_bpANN           =    corrcoef(BPoutput_pred,y_pred');
% ANNPre_R(i)       =    R_bpANN(1,2);
% int_bpANN               = find(ANNPreRMS(:,i)==min(ANNPreRMS(:,i)));
% disp([i nodenumber ANNRMS(i), ANNPreRMS(i),ANN_R(i),ANNPre_R(i)]);
end 
end
