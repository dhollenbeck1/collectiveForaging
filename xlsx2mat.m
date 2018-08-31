%% move data from xlsx to mat

% 1. manually import data as column vectors
% 2. update ang, coh, and cor 
% 3. run script

ang = 45;
coh = 1;
cor = 1;

avg_t2e = VarName3;
avg_t2d = VarName4;
part = VarName5;
tar = VarName6;

fn = ['angle_',num2str(ang),'_coh_',num2str(coh),'_cor_',num2str(cor),'.mat'];
save(fn,'avg_t2e','avg_t2d','part','tar')

clc
clear