wd = 0.1;
a = 3;
b = 1.25;
c = 2;
d = 4;
s = 15;

r = linspace(1,100,100);
ljp(r,wd,s,a,b,c,d)

function [] = ljp(radius,welldepth,sig,alph,bet,alph_coef,bet_coef)
F = 24*welldepth*( alph_coef*sig^alph./radius.^(alph+1) -...
    bet_coef*sig^bet./radius.^(bet+1) );

if length(radius) == 1
    F
else
    plot(radius,F)
    axis([0,100,-2,5])
end
end