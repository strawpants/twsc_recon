function  g=los_reg(x,y,alfa)
n=length(x);                  % the number of observation points
q=alfa;                       % the number of observations used in each local regression
v=x;
%%% calculate derta[i](vj) %%%
for i=1:length(x);
    for j=1:length(v);
        derta(i,j)=abs(x(i)-v(j));
    end
end
%%%  calculate derta[q](vj)  %%%
for j=1:length(v);
    aa=abs(x-v(j));
    bb=sort(aa);
    dertaq(j)=bb(q);
end
%%%  calculate the neighborhood weights w(i,j) %%%
for i=1:length(x);
    for j=1:length(v);
        derta_last(i,j)=min(derta(i,j)/dertaq(j),1.0);
        w(i,j)=(1-(derta_last(i,j))^3)^3;
    end
end
%%%  calculate the predicted value of Y at vj : g(j)%%%
for j=1:length(v);
    b=fminsearch(@(b) myfun(b,x,y,w,j), [0.5,0.3]);
%     g(j)=b(1)+b(2)*v(j)+b(3)*v(j)^2;
      g(j)=b(1)+b(2)*v(j);
end
end