nbins = 15;
ftsz = 18;
lnwd = 3;

subplot 221
hold on
load cohesion_on_correlation_on_1000.mat
[counts,centers] = hist(avg_t2e,nbins);
% counts = counts./((centers(2)-centers(1))*sum(counts));
plot(centers,counts,'LineWidth',lnwd)
load cohesion_on_correlation_off_1000.mat
[counts,centers] = hist(avg_t2e,nbins);
% counts = counts./((centers(2)-centers(1))*sum(counts));
plot(centers,counts,'LineWidth',lnwd)
load cohesion_off_correlation_off_1000.mat
[counts,centers] = hist(avg_t2e,nbins);
% counts = counts./((centers(2)-centers(1))*sum(counts));
plot(centers,counts,'LineWidth',lnwd)
% load cohesion_off_correlation_on_1000.mat
% [counts,centers] = hist(avg_t2e,nbins);
% counts = counts./((centers(2)-centers(1))*sum(counts));
% plot(centers,counts,'LineWidth',lnwd)
hold off
title('Average time to eat')
legend('coh_{on}cor_{on}','coh_{on}cor_{off}',...
    'coh_{off}cor_{off}')
% ,'coh_{off}cor_{on}')
xlabel('ticks')
ylabel('\rho_{t_e}','Rotation',0)
set(gca,'fontsize',ftsz)

subplot 222
hold on
load cohesion_on_correlation_on_1000.mat
[counts,centers] = hist(avg_t2d,nbins);
% counts = counts./((centers(2)-centers(1))*sum(counts));
plot(centers,counts,'LineWidth',lnwd)
%%
load cohesion_on_correlation_off_1000.mat
[counts,centers] = hist(avg_t2d,nbins);
% counts = counts./((centers(2)-centers(1))*sum(counts));
plot(centers,counts,'LineWidth',lnwd)
%%
load cohesion_off_correlation_off_1000.mat
[counts,centers] = hist(avg_t2d,nbins);
% counts = counts./((centers(2)-centers(1))*sum(counts));
plot(centers,counts,'LineWidth',lnwd)
%%
% load cohesion_off_correlation_on_1000.mat
% [counts,centers] = hist(avg_t2d,nbins);
% counts = counts./((centers(2)-centers(1))*sum(counts));
% plot(centers,counts,'LineWidth',lnwd)
hold off
title('Average time to detect')
legend('coh_{on}cor_{on}','coh_{on}cor_{off}',...
    'coh_{off}cor_{off}')
% ,'coh_{off}cor_{on}')
xlabel('ticks')
ylabel('\rho_{t_d}','Rotation',0)
set(gca,'fontsize',ftsz)

subplot 223
hold on
load cohesion_on_correlation_on_1000.mat
[counts,centers] = hist(tar,nbins);
% counts = counts./((centers(2)-centers(1))*sum(counts));
plot(centers,counts,'LineWidth',lnwd)
load cohesion_on_correlation_off_1000.mat
[counts,centers] = hist(tar,nbins);
% counts = counts./((centers(2)-centers(1))*sum(counts));
plot(centers,counts,'LineWidth',lnwd)
load cohesion_off_correlation_off_1000.mat
[counts,centers] = hist(tar,nbins);
% counts = counts./((centers(2)-centers(1))*sum(counts));
plot(centers,counts,'LineWidth',lnwd)
% load cohesion_off_correlation_on_1000.mat
% [counts,centers] = hist(tar,nbins);
% % counts = counts./((centers(2)-centers(1))*sum(counts));
% plot(centers,counts,'LineWidth',lnwd)
hold off
title('Targets found')
legend('coh_{on}cor_{on}','coh_{on}cor_{off}',...
    'coh_{off}cor_{off}')
% ,'coh_{off}cor_{on}')
xlabel('targets')
ylabel('Freq')
set(gca,'fontsize',ftsz)

subplot 224
hold on
load cohesion_on_correlation_on_1000.mat
[counts,centers] = hist(eff,nbins);
% counts = counts./((centers(2)-centers(1))*sum(counts));
plot(centers,counts,'LineWidth',lnwd)
load cohesion_on_correlation_off_1000.mat
[counts,centers] = hist(eff,nbins);
% counts = counts./((centers(2)-centers(1))*sum(counts));
plot(centers,counts,'LineWidth',lnwd)
load cohesion_off_correlation_off_1000.mat
[counts,centers] = hist(eff,nbins);
% counts = counts./((centers(2)-centers(1))*sum(counts));
plot(centers,counts,'LineWidth',lnwd)
% load cohesion_off_correlation_on_1000.mat
% [counts,centers] = hist(eff,nbins);
% % counts = counts./((centers(2)-centers(1))*sum(counts));
% plot(centers,counts,'LineWidth',lnwd)
hold off
title('Group efficiency')
legend('coh_{on}cor_{on}','coh_{on}cor_{off}',...
    'coh_{off}cor_{off}')
% ,'coh_{off}cor_{on}')
xlabel('N/L')
ylabel('Freq')
set(gca,'fontsize',ftsz)

clear