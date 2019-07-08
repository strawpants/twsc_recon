function f=myfun(b,x,y,w,jj)
f=0;
for i=1:length(x);
%     f=f+w(i,jj)*(y(i)-(b(1)+b(2)*x(i)+b(3)*x(i)^2))^2;
      f=f+w(i,jj)*(y(i)-(b(1)+b(2)*x(i)))^2;
end
end