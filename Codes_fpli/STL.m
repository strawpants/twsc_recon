function [STL_output]=STL(str_year,str_month,time,ts,np,ni,no,nl,ns,nt)

% INPUTS:
%   str_year (1,Year)      : String type year.
%     
%   str_month (1,month)    : String type month.
%   
%   time(time,1)           : Double type time.
%
%   ts(time series,n)      : Time series of nth input data.
%
%   np    : The number of observations in each cycle of the seasonal component.
%           
%   ni    : The number of passes through the inner loop.
%
%   no    : The number of robustness iteration of the outer loop.
%
%   nl    : The smoothing parameter for the low-pass filer.
%
%   ns    : The smoothing parameter for the seasonal component.
%
%   nt    : The smoothing parameter for the trend component.
%
% OUTPUTS:
%   STL_output (t, 7) : Seven columns of output data refering to time,
%   original,seasonal,trend,linear, inter annual and residuals respectively.
%
% AUTHORS:
%   Fupeng Li
%   SGG,Wuhan University,China
%   First created in Nov.27, 2018.  
%   Email:fpli@whu.edu.cn
%
% Reference:
%   Cleveland RB, Cleveland WS, McRae JE, Terpenning I (1990) STL: a seasonal
%   trend decomposition procedure based on loess. J Off Stat 6:3?73

%begain
[t n]=size(ts);
tgap = 0;
%% ===========Fill the time gap and interpolation==========================
%  Warning: These codes cannot fill data with continuous missing which
%  including Dec.or Jan.
 for j=1:n
 for i=1:t
    i=i+tgap;
    time1(i,1)=str2double(str_year(i-tgap));
    if (i>1&&time1(i-1,1)==2015&&time1(i-1,2)==4&&str2double(str_month(i-tgap))==4)
    time1(i,2)=str2double(str_month(i-tgap))+1;
    else
    time1(i,2)=str2double(str_month(i-tgap));
    end
    time1(i,3)=time(i-tgap);
    time1(i,4)=ts(i-tgap,j);
    if(i>1)
    a1=time1(i,3);
    b1=time1(i-1,3);
    a=time1(i,4);
    b=time1(i-1,4);
    gap=time1(i,2)-time1(i-1,2);
     if(gap>1)
       tgap=tgap+gap-1;
       time1(i+gap-1,1)=time1(i,1);
       time1(i+gap-1,2)=time1(i,2);
       time1(i+gap-1,3)=time1(i,3);
       time1(i+gap-1,4)=time1(i,4);
       for k=1:gap-1
         time1(i+k-1,1)=time1(i,1);
         time1(i+k-1,2)=time1(i-1,2)+k;
         time1(i+k-1,3)=b1+k*(a1-b1)/gap; 
         time1(i+k-1,4)=b+k*(a-b)/gap; 
       end
     end
     if (time1(i-1,2)==11&&time1(i,2)~=12)
       a1=time1(i,3);
       b1=time1(i-1,3); 
       a=time1(i,4);
       b=time1(i-1,4); 
       gap=2;
       tgap=tgap+gap-1;
       time1(i+gap-1,1)=time1(i,1);
       time1(i+gap-1,2)=time1(i,2);
       time1(i+gap-1,3)=time1(i,3);
       time1(i+gap-1,4)=time1(i,4);
       for k=1:gap-1
         time1(i+k-1,1)=time1(i,1);
         time1(i+k-1,2)=12;
         time1(i+k-1,3)=b1+k*(a1-b1)/gap;
         time1(i+k-1,4)=b+k*(a-b)/gap;
       end
     end
     if (time1(i,2)==2&&time1(i-1,2)~=1)
       a1=time1(i,3);
       b1=time1(i-1,3); 
       a=time1(i,4);
       b=time1(i-1,4); 
       gap=2;
       tgap=tgap+gap-1;
       time1(i+gap-1,1)=time1(i,1);
       time1(i+gap-1,2)=time1(i,2);
       time1(i+gap-1,3)=time1(i,3);
       time1(i+gap-1,4)=time1(i,4);
       for k=1:gap-1
         time1(i+k-1,1)=time1(i,1);
         time1(i+k-1,2)=1;
         time1(i+k-1,3)=b1+k*(a1-b1)/gap;
         time1(i+k-1,4)=b+k*(a-b)/gap;
       end
     end
    end
 end
 end
 t=t+tgap;
 T=zeros(t,1);
 TT=zeros(t,1);
 X=zeros(t);
 Y=zeros(t,n);
 STL_output=zeros(t,4,n);
 X=time1(:,3);
 time2=time1;
%% ====================Inner loop==========================================
for u=1:n
    Y(:,u)=time1(:,4);
for k=1:ni
%----------------Detrending------------------------------------------------       
    Y(:,u)=Y(:,u)-T(:,1);
    time1(:,4)=Y(:,u);
%----------------Cycle-subseries Smoothing---------------------------------
  for m=1:np
    v=1;
    for i=1:t
        if (time1(i,2)==m)
            C1(v,m,:)=time1(i,:);
            v=v+1;
        end
    end
  end
d=C1(:,:,3);
e=C1(:,:,4);
[p q]=size(d);
for i=1:np
    k=1;
    for j=1:p
        if (e(j,i)~=0&&d(j,i)~=0)
            e1(k,i)=e(j,i);
            d1(k,i)=d(j,i);
            k=k+1;
        end
    end
    CSS(1:k+1,i)=los_reg_extend(d1(1:k-1,i),e1(1:k-1,i),ns);
    d(1,i)=d1(1,i)-1;
    d(2:k,i)=d1(1:k-1,i);
    d(k+1,i)=d1(k-1,i)+1;
end
k=1;
for i=1:p+2
    for j=1:np
        if (d(i,j)~=0&&CSS(i,j)~=0)
        C2(k,1)=d(i,j);
        C3(k,1)=CSS(i,j);
        k=k+1;
        end
    end
end
[C22 I]=sort(C2);
C(:,1)=C22;
C(:,2)=C3(I,1);
%----------------Low-Pass Filtering of SmoothedCycle-Subseries-------------
if mod(np,2)==0
j=np/2;
k=t+1.5*np;
for i=j:k
    L1(i-j+1,1)=sum(C(i-j+1:i+np/2,2))/np;
end
for i=j:k-np+1
    L2(i-j+1,1)=sum(L1(i-j+1:i+np/2,1))/np;
end
for i=2:t+1
    L3(i-1,1)=sum(L2(i-1:i+1,1))/3;
end
    L(:,1)=L3(:,1);
else
j=floor(np/2);
k=t+np+j+1;
for i=j+1:k
    L1(i-j,1)=sum(C(i-j:i+j,2))/np;
end
for i=j+1:k-np+1
    L2(i-j,1)=sum(L1(i-j:i+j,1))/np;
end
for i=2:t+1
    L3(i-1,1)=sum(L2(i-1:i+1,1))/3;
end
    L(:,1)=L3(:,1);
end
%----------------Detrending of SmoothedCycle-Subseries---------------------
S(:,1)=C(np+1:t+np,2)-L(:,1);
%----------------Deseasonalizing-------------------------------------------
Non_S(:,1)=Y(:,u)-S(:,1);
%----------------Trend Smoothing-------------------------------------------
T(:,1)=los_reg(C(np+1:t+np,1),Non_S(:,1),nl);
TT(:,1)=TT(:,1)+T(:,1);
%----------------Linear and Inter Annual Decomposition---------------------
 P = polyfit(C(np+1:t+np,1),TT(:,1),1);
 Linear(:,1)=polyval(P,C(np+1:t+np));
 Inter(:,1)=TT(:,1)-Linear(:,1);
%----------------Resisuals-------------------------------------------------
Res(:,1)=time2(:,4)-S(:,1)-TT(:,1);
end
%% ====================Outputs==============================================
STL_output(:,1,u)=C(np+1:t+np,1);%Time
STL_output(:,2,u)=time2(:,4);%Original
STL_output(:,3,u)=S(:,1);%Seasonal
STL_output(:,4,u)=TT(:,1);%Trend
STL_output(:,5,u)=Linear(:,1);%Linear
STL_output(:,6,u)=Inter(:,1);%Inter Annual
STL_output(:,7,u)=Res(:,1);%Residuals
end
end

