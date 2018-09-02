wd = 1;
s = 15;
s = 0.8*s
a = 2;
b = 1.5;
c = s;
d = s;


r = linspace(1,100,100);
ljp(r,wd,s,a,b,c,d)

function [] = ljp(radius,welldepth,sig,alph,bet,alph_coef,bet_coef)
F = 24*welldepth*( alph_coef*sig^alph./radius.^(alph+1) -...
    bet_coef*sig^bet./radius.^(bet+1) );

if length(radius) == 1
    F
else
    plot(radius,F)
    axis([0,100,-10,10])
end
end