nbins=10;
ftsz = 18;
lnwd = 3;


bw = 40;
subplot 221
load cohesion_on_correlation_on_1000.mat
h1 = histogram(avg_t2e,nbins,'Normalization','probability');
h1.BinWidth = bw;
x1 = h1.BinEdges; y1 = h1.Values;
x1 = x1(1:end-1)+diff(x1);
load cohesion_on_correlation_off_1000.mat
h2 = histogram(avg_t2e,nbins,'Normalization','probability');
h2.BinWidth = bw;
x2 = h2.BinEdges; y2 = h2.Values;
x2 = x2(1:end-1)+diff(x2);
load cohesion_off_correlation_off_1000.mat
h3 = histogram(avg_t2e,nbins,'Normalization','probability');
h3.BinWidth = bw;
x3 = h3.BinEdges; y3 = h3.Values;
x3 = x3(1:end-1)+diff(x3);
% load cohesion_off_correlation_on_1000.mat
% h4 = histogram(avg_t2e,nbins,'Normalization','probability');
% h4.BinWidth = bw;
% x4 = h4.BinEdges; y4 = h4.Values;
% x4 = x4(1:end-1)+diff(x4);

plot(x1,y1,x2,y2,x3,y3,'LineWidth',lnwd)
title('Average time to eat')
% plot(x1,y1,x2,y2,x3,y3,x4,y4,'LineWidth',lnwd)
legend('coh_{on}cor_{on}','coh_{on}cor_{off}','coh_{off}cor_{off}')
% legend('coh_{on}cor_{on}','coh_{on}cor_{off}','coh_{off}cor_{off}','coh_{off}cor_{on}')
xlabel('ticks')
ylabel('P_{te}','Rotation',0)
set(gca,'fontsize',ftsz)
%%
bw = 100;
subplot 222
load cohesion_on_correlation_on_1000.mat
h1 = histogram(avg_t2d,nbins,'Normalization','probability');
h1.BinWidth = bw;
x1 = h1.BinEdges; y1 = h1.Values;
x1 = x1(1:end-1)+diff(x1);
% bw = 200;
load cohesion_on_correlation_off_1000.mat
h2 = histogram(avg_t2d,nbins,'Normalization','probability');
h2.BinWidth = bw;
x2 = h2.BinEdges; y2 = h2.Values;
x2 = x2(1:end-1)+diff(x2);
load cohesion_off_correlation_off_1000.mat
h3 = histogram(avg_t2d,nbins,'Normalization','probability');
h3.BinWidth = bw;
x3 = h3.BinEdges; y3 = h3.Values;
x3 = x3(1:end-1)+diff(x3);
% load cohesion_off_correlation_on_1000.mat
% h4 = histogram(avg_t2d,nbins,'Normalization','probability');
% h4.BinWidth = bw;
% x4 = h4.BinEdges; y4 = h4.Values;
% x4 = x4(1:end-1)+diff(x4);

plot(x1,y1,x2,y2,x3,y3,'LineWidth',lnwd)
title('Average time to detect')
% plot(x1,y1,x2,y2,x3,y3,x4,y4,'LineWidth',lnwd)
legend('coh_{on}cor_{on}','coh_{on}cor_{off}','coh_{off}cor_{off}')
% legend('coh_{on}cor_{on}','coh_{on}cor_{off}','coh_{off}cor_{off}','coh_{off}cor_{on}')
xlabel('ticks')
xlim([0,10000])
ylabel('P_{td}','Rotation',0)
set(gca,'fontsize',ftsz)


%%
bw = 2;
subplot 223
load cohesion_on_correlation_on_1000.mat
h1 = histogram(tar,nbins,'Normalization','probability');
h1.BinWidth = bw;
x1 = h1.BinEdges; y1 = h1.Values;
x1 = x1(1:end-1)+diff(x1);
load cohesion_on_correlation_off_1000.mat
h2 = histogram(tar,nbins,'Normalization','probability');
h2.BinWidth = bw;
x2 = h2.BinEdges; y2 = h2.Values;
x2 = x2(1:end-1)+diff(x2);
load cohesion_off_correlation_off_1000.mat
h3 = histogram(tar,nbins,'Normalization','probability');
h3.BinWidth = bw;
x3 = h3.BinEdges; y3 = h3.Values;
x3 = x3(1:end-1)+diff(x3);
% load cohesion_off_correlation_on_1000.mat
% h4 = histogram(tar,nbins,'Normalization','probability');
% h4.BinWidth = bw;
% x4 = h4.BinEdges; y4 = h4.Values;
% x4 = x4(1:end-1)+diff(x4);

plot(x1,y1,x2,y2,x3,y3,'LineWidth',lnwd)
title('Number of targets found')
% plot(x1,y1,x2,y2,x3,y3,x4,y4,'LineWidth',lnwd)
legend('coh_{on}cor_{on}','coh_{on}cor_{off}','coh_{off}cor_{off}')
% legend('coh_{on}cor_{on}','coh_{on}cor_{off}','coh_{off}cor_{off}','coh_{off}cor_{on}')
xlabel('number of targets')
ylabel('P_{tar}','Rotation',0)
set(gca,'fontsize',ftsz)
%%

tot_mov = 12275;
effscale = 1000;
bw = 1000;
nbins = 10;
subplot 224
load cohesion_on_correlation_on_1000.mat
h1 = histogram(effscale*(tot_mov-tar./eff),nbins,'Normalization','probability');
h1.BinWidth = bw;
x1 = h1.BinEdges; y1 = h1.Values;
x1 = x1(1:end-1)+diff(x1);
load cohesion_on_correlation_off_1000.mat
h2 = histogram(effscale*(tot_mov-tar./eff),'Normalization','probability');
h2.BinWidth = bw;
x2 = h2.BinEdges; y2 = h2.Values;
x2 = x2(1:end-1)+diff(x2);
load cohesion_off_correlation_off_1000.mat
h3 = histogram(effscale*(tot_mov-tar./eff),'Normalization','probability');
h3.BinWidth = bw;
x3 = h3.BinEdges; y3 = h3.Values;
x3 = x3(1:end-1)+diff(x3);
% load cohesion_off_correlation_on_1000.mat
% h4 = histogram(eff,nbins,'Normalization','probability');
% h4.BinWidth = bw;
% x4 = h4.BinEdges; y4 = h4.Values;
% x4 = x4(1:end-1)+diff(x4);

plot(x1,y1,x2,y2,x3,y3,'LineWidth',lnwd)
title('Group Efficiency')
% plot(x1,y1,x2,y2,x3,y3,x4,y4,'LineWidth',lnwd)
legend('coh_{on}algn_{on}','coh_{on}cor_{off}','coh_{off}cor_{off}')
% legend('coh_{on}cor_{on}','coh_{on}cor_{off}','coh_{off}cor_{off}','coh_{off}cor_{on}')
xlabel('\eta = L')
ylabel('P_{eff}','Rotation',0)
set(gca,'fontsize',ftsz)

% clear