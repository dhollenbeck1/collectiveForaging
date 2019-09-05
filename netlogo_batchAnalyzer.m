clc
clear

% file related settings
fpath = 'C:\Users\drkfr\Desktop\NSF\collectiveForaging\03202019\';
[d,numfiles,numdir] = getfpathinfo(fpath);
fsavename = 'data_cf_03202019';

% script settings
getrawdata = 0;
plotdata = 1;

%% get raw data
if getrawdata == 1
    for i = 1: numfiles
        
        data(i).fn = d(numdir+i).name;
        data(i).coh = str2num(data(i).fn(5));
        data(i).aln = str2num(data(i).fn(13));
        
        if data(i).coh == 1
            s1 = 'on';
        else
            s1 = 'off';
        end
        
        if data(i).aln == 1 
            s2 = 'on';
        else
            s2 = 'off';
        end
        data(i).name = ['coh=',s1,', aln=',s2];
        
        fid = fopen([fpath,'\',data(i).fn]);
        
        for j=1:7
            C = fgetl(fid);
        end
        
        tar = []; t2d = []; t2e = []; csm = []; f2d = []; viv = [];
        while C~=-1
            C = fgetl(fid);
            if C == -1
                break
            end
            k = find(C==',');
            tar = [tar;str2double(C(k(8)+2:k(9)-2))];
            t2d = [t2d;str2double(C(k(9)+2:k(10)-2))];
            t2e = [t2e;str2double(C(k(10)+2:k(11)-2))];
            csm = [csm;eval(C(k(11)+2:k(12)-2))];
            f2d = [f2d;eval(C(k(12)+2:k(13)-2))];
            viv = [viv;eval(C(k(13)+2:end-1))];
        end
        
        data(i).tar = tar;
        data(i).t2d = t2d;
        data(i).t2e = t2e;
        data(i).csm = csm;
        data(i).f2d = f2d;
        data(i).viv = viv;
        
        fclose(fid);
    end
    save(fsavename,'data')
end

%% plot data
if plotdata == 1
    load(fsavename)
    len = length(data);
    ftsz = 18;
    lnwd = 3;
    nx = 100;
    linecolor = [[0.9290, 0.6940, 0.1250];...
        [0.4940, 0.1840, 0.5560];...
        [0.8500, 0.3250, 0.0980];...
        [0, 0.4470, 0.7410]];
    
    % plot 1: t2d
    subplot 321
    nbins=18;bw = 150;   
    for i=1:len
        h1 = histogram(data(i).t2d,nbins,'Normalization','probability');
        h1.BinWidth = bw;
        data(i).x = h1.BinEdges; data(i).y = h1.Values;
        h1.FaceColor = 'none';
        h1.EdgeColor = 'none';
        data(i).x = data(i).x(1:end-1)+diff(data(i).x);
        
%         xq = linspace(min(data(i).x),max(data(i).x),nx);
%         vq = interp1(data(i).x,data(i).y,xq);
%         data(i).x = xq; data(i).y = vq;
    end
    plot(data(1).x,data(1).y,'Color',linecolor(1,:),'LineWidth',lnwd);hold on
    plot(data(2).x,data(2).y,'Color',linecolor(2,:),'LineWidth',lnwd);
    plot(data(3).x,data(3).y,'Color',linecolor(3,:),'LineWidth',lnwd);
    plot(data(4).x,data(4).y,'Color',linecolor(4,:),'LineWidth',lnwd); hold off
    set(gca,'FontSize',16)
    legend(data(1).name,data(2).name,data(3).name,data(4).name)
    title('Avg time-to-detect PDF');
    xlabel('ticks');
    xlim([0,6000])
    
    
    % plot 2: t2e
    subplot 322
    nbins=10;bw = 55;
    for i=1:len
        h1 = histogram(data(i).t2e,nbins,'Normalization','probability');
        h1.BinWidth = bw;
        data(i).x = h1.BinEdges; data(i).y = h1.Values;
        h1.FaceColor = 'none';
        h1.EdgeColor = 'none';
        data(i).x = data(i).x(1:end-1)+diff(data(i).x);
        
    end
    plot(data(1).x,data(1).y,'Color',linecolor(1,:),'LineWidth',lnwd);hold on
    plot(data(2).x,data(2).y,'Color',linecolor(2,:),'LineWidth',lnwd);
    plot(data(3).x,data(3).y,'Color',linecolor(3,:),'LineWidth',lnwd);
    plot(data(4).x,data(4).y,'Color',linecolor(4,:),'LineWidth',lnwd); hold off
    set(gca,'FontSize',16)
    title('Avg time-to-eat PDF');legend(data(1).name,data(2).name,data(3).name,data(4).name)
    legend(data(1).name,data(2).name,data(3).name,data(4).name)
    xlabel('ticks');
    xlim([0,520]); ylim([0,1])
   
    
    % plot 3: targets
    subplot 323
    nbins=10;bw = 2;
    for i=1:len
        h1 = histogram(data(i).tar,nbins,'Normalization','probability');
        h1.BinWidth = bw;
        data(i).x = h1.BinEdges; data(i).y = h1.Values;
        h1.FaceColor = 'none';
        h1.EdgeColor = 'none';
        data(i).x = data(i).x(1:end-1)+diff(data(i).x);
        
    end
    plot(data(1).x,data(1).y,'Color',linecolor(1,:),'LineWidth',lnwd);hold on
    plot(data(2).x,data(2).y,'Color',linecolor(2,:),'LineWidth',lnwd);
    plot(data(3).x,data(3).y,'Color',linecolor(3,:),'LineWidth',lnwd);
    plot(data(4).x,data(4).y,'Color',linecolor(4,:),'LineWidth',lnwd); hold off
    set(gca,'FontSize',16)
    title('Targets found PDF')
    legend(data(1).name,data(2).name,data(3).name,data(4).name)
    xlabel('targets');
    xlim([0,30])
    
    
    % plot 4: vultures in view
    subplot 324
    nbins=10;bw = 1;
    for i=1:len
        temp = data(i).viv;
        ss = size(temp);
        temp = reshape(temp,[1,ss(1)*ss(2)]);
        k = find(temp == 0);
        if length(k) > 1000
           k = k(1:1000); 
        end
        temp(k)=[];
        h1 = histogram(temp,nbins,'Normalization','probability');
        h1.BinWidth = bw;
        data(i).x = h1.BinEdges; data(i).y = h1.Values;
        h1.FaceColor = 'none';
        h1.EdgeColor = 'none';
        data(i).x = data(i).x(1:end-1)+diff(data(i).x)-1;      
    end
    plot(data(1).x,data(1).y,'Color',linecolor(1,:),'LineWidth',lnwd);hold on
    plot(data(2).x,data(2).y,'Color',linecolor(2,:),'LineWidth',lnwd);
    plot(data(3).x,data(3).y,'Color',linecolor(3,:),'LineWidth',lnwd);
    plot(data(4).x,data(4).y,'Color',linecolor(4,:),'LineWidth',lnwd); hold off
    set(gca,'FontSize',16)
    title('Vultures-in-view PDF')
%     legend show
    legend(data(1).name,data(2).name,data(3).name,data(4).name)
    xlabel('vultures');
    xlim([0,11])
    
    % plot 5: consume
    subplot 325
    nbins=10;bw = 100;
    for i=1:len
        temp = data(i).csm;
        ss = size(temp);
        temp = reshape(temp,[1,ss(1)*ss(2)]);
        k = find(temp == 0);
        if length(k) > 1000
           k = k(1:1000); 
        end
        temp(k)=[];
        h1 = histogram(temp,nbins,'Normalization','probability');
        h1.BinWidth = bw;
        data(i).x = h1.BinEdges; data(i).y = h1.Values;
        h1.FaceColor = 'none';
        h1.EdgeColor = 'none';
        data(i).x = data(i).x(1:end-1)+diff(data(i).x);
        
    end
    plot(data(1).x,data(1).y,'Color',linecolor(1,:),'LineWidth',lnwd);hold on
    plot(data(2).x,data(2).y,'Color',linecolor(2,:),'LineWidth',lnwd);
    plot(data(3).x,data(3).y,'Color',linecolor(3,:),'LineWidth',lnwd);
    plot(data(4).x,data(4).y,'Color',linecolor(4,:),'LineWidth',lnwd); hold off
    set(gca,'FontSize',16)
    title('Consumption PDF')
    legend(data(1).name,data(2).name,data(3).name,data(4).name)
    xlabel('health points');
    xlim([0,2000]); ylim([0,0.5])
    
    
    % plot 6: f2d
    subplot 326
    nbins=6;bw = 1;
    for i=1:len
        temp = data(i).f2d;
        ss = size(temp);
        temp = reshape(temp,[1,ss(1)*ss(2)]);
        k = find(temp == 0);
        if length(k) > 1000
           k = k(1:1000); 
        end
        temp(k)=[];
        h1 = histogram(temp,nbins,'Normalization','probability');
        h1.BinWidth = bw;
        data(i).x = h1.BinEdges; data(i).y = h1.Values;
        h1.FaceColor = 'none';
        h1.EdgeColor = 'none';
        data(i).x = data(i).x(1:end-1)+diff(data(i).x);
        
        
    end
    plot(data(1).x,data(1).y,'Color',linecolor(1,:),'LineWidth',lnwd);hold on
    plot(data(2).x,data(2).y,'Color',linecolor(2,:),'LineWidth',lnwd);
    plot(data(3).x,data(3).y,'Color',linecolor(3,:),'LineWidth',lnwd);
    plot(data(4).x,data(4).y,'Color',linecolor(4,:),'LineWidth',lnwd); hold off
    set(gca,'FontSize',16)
    title('First-to-detect PDF')
    legend(data(1).name,data(2).name,data(3).name,data(4).name)
    xlabel('frequency');
    xlim([0,7])
    
    
    figure
    
    ll = [{data(4).name},{data(2).name},{data(3).name},{data(1).name}];
    subplot 321
    temp = [data(4).tar,data(2).tar,data(3).tar,data(1).tar];
    boxplot(temp,ll)
    set(gca,'FontSize',16)
    title('Targets Found')
    subplot 322
    temp = [data(4).t2d,data(2).t2d,data(3).t2d,data(1).t2d];
    boxplot(temp,ll)
    set(gca,'FontSize',16)
    title('Time to detect')
    subplot 323
    temp = [data(4).t2e,data(2).t2e,data(3).t2e,data(1).t2e];
    boxplot(temp,ll)
    set(gca,'FontSize',16)
    title('Time to eat')
    subplot 324
    sz = [11000,1];
    temp = [reshape(data(4).csm,sz),reshape(data(2).csm,sz),reshape(data(3).csm,sz),reshape(data(1).csm,sz)];
    boxplot(temp,ll)
    set(gca,'FontSize',16)
    title('Total amount target consumed')
    subplot 325
    sz = [11000,1];
    temp = [reshape(data(4).f2d,sz),reshape(data(2).f2d,sz),reshape(data(3).f2d,sz),reshape(data(1).f2d,sz)];
    boxplot(temp,ll)
    set(gca,'FontSize',16)
    title('First to detect')
    subplot 326
    sz = [11000,1];
    temp = [reshape(data(4).viv,sz),reshape(data(2).viv,sz),reshape(data(3).viv,sz),reshape(data(1).viv,sz)];
    boxplot(temp,ll)
    set(gca,'FontSize',16)
    title('Agents in view')
end
%% FUNCTIONS
function [d,numfiles,numdir] = getfpathinfo(fpath)
% get num of files / dir
d = dir(fpath);
numfiles = sum(not([d.isdir]));
numdir = sum([d.isdir]);
end