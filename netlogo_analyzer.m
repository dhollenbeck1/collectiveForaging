%% NetLogo Analyzer
% by Derek Hollenbeck
%
% Program takes in NetLogo data from vultures_user.nlogo that is
% pre-processed by xlsx2mat.m
%
% Analysis type
% 1. hist/pdf of each combination

%% Settings
analysisType = 1;
angle = 180;
nbins = 8;
% prompt user
display(['analysis type: ',num2str(analysisType)]);

%% Main
switch analysisType
    
    case 1
        
        for k=1:length(angle)
            figure
            
            % time 2 eat loop
            subplot(2,2,1)            % update sub figure
            hold on
            for i=1:2
                for j=1:2                 
                    % load file
                    fn = ['angle_',num2str(angle(k)),'_coh_',num2str(j-1),'_cor_',num2str(i-1)];
                    load(fn)                   
                    % create hist
                    [counts,centers] = hist(avg_t2e,nbins);
%                     counts = counts./((centers(2)-centers(1))*sum(counts));
                    plot(centers,counts);    
                                     
                end
            end
            hold off
            title('Time 2 eat')
            legend('coh_{off}cor_{off}','coh_{on}cor_{off}',...
                'coh_{off}cor_{on}','coh_{on}cor_{on}')
            xlabel('time, ticks')
            ylabel('freq')
            
            % time to detection loop
            subplot(2,2,2)            % update sub figure
            hold on
            for i=1:2
                for j=1:2                 
                    % load file
                    fn = ['angle_',num2str(angle(k)),'_coh_',num2str(j-1),'_cor_',num2str(i-1)];
                    load(fn)                   
                    % create hist
                    [counts,centers] = hist(avg_t2d,nbins);
%                     counts = counts./((centers(2)-centers(1))*sum(counts));
                    plot(centers,counts);    
                                     
                end
            end
            hold off
            title('Time 2 Detect')
            legend('coh_{off}cor_{off}','coh_{on}cor_{off}',...
                'coh_{off}cor_{on}','coh_{on}cor_{on}')
            xlabel('time, ticks')
            ylabel('freq')
            
            % target count
            subplot(2,2,3)            % update sub figure
            hold on
            for i=1:2
                for j=1:2                 
                    % load file
                    fn = ['angle_',num2str(angle(k)),'_coh_',num2str(j-1),'_cor_',num2str(i-1)];
                    load(fn)                   
                    % create hist
                    [counts,centers] = hist(tar,nbins);
%                     counts = counts./((centers(2)-centers(1))*sum(counts));
                    plot(centers,counts);    
                                     
                end
            end
            hold off
            title('Target Count')
            legend('coh_{off}cor_{off}','coh_{on}cor_{off}',...
                'coh_{off}cor_{on}','coh_{on}cor_{on}')
            xlabel('targets')
            ylabel('freq')
            
            % efficiency
            subplot(2,2,4)            % update sub figure
            hold on
            for i=1:2
                for j=1:2                 
                    % load file
                    fn = ['angle_',num2str(angle(k)),'_coh_',num2str(j-1),'_cor_',num2str(i-1)];
                    load(fn)                   
                    % create hist
                    eff = 1./(avg_t2e.*avg_t2d);
                    [counts,centers] = hist(eff,nbins);
%                     counts = counts./((centers(2)-centers(1))*sum(counts));
                    plot(centers,counts);    
                                     
                end
            end
            hold off
            title('Efficiency')
            legend('coh_{off}cor_{off}','coh_{on}cor_{off}',...
                'coh_{off}cor_{on}','coh_{on}cor_{on}')
            xlabel('\eta')
            ylabel('freq')
        end
        
    otherwise
        display('Invalid Type')
end