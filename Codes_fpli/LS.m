function [LS_output]=LS(time,ts,s)

% INPUTS:
%   
%   time(time,1)           : Double type time.
%
%   ts(time series,n)      : Time series of n-th input data.
%
%   s                      : Ceil (1.5*seasonal).
%
% OUTPUTS:
%   STL_output (t, 7) : Seven columns of output data refering to time,
%   original,seasonal,trend,linear, inter annual, and residuals respectively.
%
% AUTHORS:
%   Fupeng Li
%   SGG,Wuhan University,China  
%   Email:fpli@whu.edu.cn
%

%begain
[t n]=size(ts);
m=floor(t/s);
r=t-s*m;
%% ===========Fill the time gap and interpolation==========================
%  Warning: These codes cannot fill data with continuous missing which
%  including Dec.or Jan.
% inter=zeros(t,n);
k=1;
v=floor(s/3);

for j=1:n
     func_sin = @(b,t) b(1)*sin(2*pi*time+b(2))+b(3)*cos(2*pi*time+b(4))+b(5)*sin(4*pi*time+b(6))+b(7)*cos(4*pi*time+b(8))+b(9)*sin(8*pi*time+b(10))+b(11)*cos(8*pi*time+b(12))+b(13)*sin(8*pi*time+b(14))+b(15)*cos(8*pi*time+b(16))+b(17);
     Aw= lsqcurvefit( func_sin, [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1], time, ts(:,j));
%      func_sin = @(b,t) b(1)*sin(2*pi*time+b(2))+b(3)*cos(2*pi*time+b(4))+b(5)*sin(4*pi*time+b(6))+b(7)*cos(4*pi*time+b(8))+b(9);
%      Aw= lsqcurvefit( func_sin, [1 1 1 1 1 1 1 1 1], time, ts(:,j));
%      func_sin = @(b,t) b(1)*sin(2*pi*time+b(2))+b(3)*cos(2*pi*time+b(4))+b(5);
%      Aw= lsqcurvefit( func_sin, [1 1 1 1 1], time, ts(:,j));
     sea(:,j)=func_sin(Aw,time);
     res1(:,j)=ts(:,j)-sea(:,j);
     for i=1:m
         if i==1
           p  = polyfit(time((i-1)*s+1:i*s), res1((i-1)*s+1:i*s,j), 3);
           inter((i-1)*s+1:i*s,j) = polyval(p, time((i-1)*s+1:i*s));
         else
           p  = polyfit(time((i-1)*s-k:i*s), res1((i-1)*s-k:i*s,j), 3);
           inter((i-1)*s-k:(i-1)*s,j) =(inter((i-1)*s-k:(i-1)*s,j)+ polyval(p, time((i-1)*s-k:(i-1)*s)))/2;
           inter((i-1)*s+1:i*s,j) = polyval(p, time((i-1)*s+1:i*s));
         end
     end
     p  = polyfit(time(m*s-k:m*s+r), res1(m*s-k:i*s+r,j), 3);
     inter(m*s-k:m*s,j) = polyval(p, time(m*s-k:m*s));
     inter(m*s+1:m*s+r,j) = polyval(p, time(m*s+1:m*s+r));
     for i=1:m-1
         p  = polyfit(time(i*s-k-v:i*s+v), inter(i*s-k-v:i*s+v,j), 3);
         inter(i*s-k-v:i*s+v,j) = polyval(p, time(i*s-k-v:i*s+v));
     end
     p  = polyfit(time(m*s-k-v:end), inter(m*s-k-v:end,j), 3);
         inter(m*s-k-v:end,j) = polyval(p, time(m*s-k-v:end));
     res(:,j)=res1(:,j)-inter(:,j);
     p=polyfit(time, inter(:,j), 1);
%      ave(j,1)=sum(polyval(p, time))/t;
%% ====================Outputs==============================================
     LS_output(:,1,j)=time;%Time
     LS_output(:,2,j)=ts(:,j);%Original
     LS_output(:,3,j)=sea(:,j);%Seasonal
     LS_output(:,4,j)=inter(:,j);%Trend
     LS_output(:,5,j)=polyval(p, time);%Linear
     LS_output(:,6,j)=inter(:,j)-polyval(p, time);%Inter
     LS_output(:,7,j)=res(:,j);%Residual
end
end

