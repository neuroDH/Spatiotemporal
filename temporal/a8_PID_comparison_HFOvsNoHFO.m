%% Cleaning
clear; close all;clc;

%% Load variables
load('HFO_BST.mat')

%% Compute PID_A, PID_D, PID_Slope and PID_IEF

str_Data_Path = './Data_HFO/';
s_SampRate = 10000;

stru_MergData(6).PID_B(412)=[];
stru_MergData(6).PID_E(412)=[];

for i=1:numel(stru_MergData)

    str_Slice = stru_MergData(i).Slice;
    str_Load = strcat(str_Data_Path,str_Slice,'.mat');
    load(str_Load,'v_FilData')

    v_Ini = stru_MergData(i).PID_B;
    v_Fin = stru_MergData(i).PID_E;

    v_Slope = [];
    v_PeakIndx = [];
    v_PID_A = [];

    for j=1:numel(v_Ini)
        
        v_Seg = v_FilData(v_Ini(j):v_Fin(j));
        [s_Max,s_IndMax] = max(abs(v_Seg));

        s_ValInf = floor(0.1*s_IndMax);
        s_ValSup = floor(0.9*s_IndMax);

        v_SlopeSeg = v_Seg(s_ValInf:s_ValSup);
        v_SlopeTim = [0:numel(v_SlopeSeg)-1]./s_SampRate;

        [a,~] = polyfit (v_SlopeTim,v_SlopeSeg, 1);

        v_Slope(j) = a(1);
        v_PeakIndx(j) = v_Ini(j)+s_IndMax;
        v_PID_A(j) = s_Max;

    end

    v_PID_D = (v_Fin-v_Ini)/s_SampRate;

    stru_MergFeat(i).PID_A = v_PID_A;
    stru_MergFeat(i).PID_D = v_PID_D;
    stru_MergFeat(i).PID_slope = v_Slope;
    stru_MergFeat(i).PID_IEF = 1./(diff(v_PeakIndx)./s_SampRate);

end

%% Associate each PID with an HFO

figure('Position',[126 195 1050 1066])
cll_HFO = {'NOHFO','HFO'};
str_Feature = 'S';
v_SubPlot = [0,2,4];

for x=1:numel(cll_HFO)

    str_HFO = cll_HFO{x};
    v_SubPlot = v_SubPlot+1;
    v_Lims = [0,1.2];

    [v_B_Bag, v_S_Bag,v_T_Bag, v_B_A_Bag,v_S_A_Bag,v_T_A_Bag,v_BarPlot,v_Erro,stru_Joint] = ...
        f_Plot_Asociated_HFO(stru_MergData,stru_MergFeat,str_HFO,str_Feature);

    subplot(3,2,v_SubPlot(1))
    plot(v_B_A_Bag,v_B_Bag,'*b')
    hold on
    plot(v_S_A_Bag+1,v_S_Bag,'*m')
    plot(v_T_A_Bag+2,v_T_Bag,'*r')
    ylim(v_Lims)
    ylabel('norm feature')
    xlabel('norm time peer period')
    title(str_HFO)

    subplot(3,2,v_SubPlot(2))

    b = bar(v_BarPlot);
    hold on
    %set(b, 'FaceAlpha', 0.2);
    b.FaceColor = 'flat';
    b.LineWidth = 0.8;
    b.CData(1,:) = [0 0 1];
    b.CData(2,:) = [0 0 1];
    b.CData(3,:) = [0 0 1];
    b.CData(4,:) = [0 0 1];
    b.CData(5,:) = [0 0 1];
    b.CData(6,:) = [0 0 1];
    b.CData(7,:) = [0 0 1];
    b.CData(8,:) = [0 0 1];
    b.CData(9,:) = [0 0 1];
    b.CData(10,:) = [0 0 1];
    b.CData(11,:) = [1 0 1];
    b.CData(12,:) = [1 0 1];
    b.CData(13,:) = [1 0 1];
    b.CData(14,:) = [1 0 1];
    b.CData(15,:) = [1 0 1];
    b.CData(16,:) = [1 0 1];
    b.CData(17,:) = [1 0 1];
    b.CData(18,:) = [1 0 1];
    b.CData(19,:) = [1 0 1];
    b.CData(20,:) = [1 0 1];
    b.CData(21,:) = [1 0 0];
    b.CData(22,:) = [1 0 0];
    b.CData(23,:) = [1 0 0];
    errorbar(v_BarPlot,v_Erro,'.k','LineWidth',0.8,'Color',[0.4,0.4,0.4])
    ylim(v_Lims)
    ylabel('mean norm feature')
    xlabel('bins')

    subplot(3,2,v_SubPlot(3))
    b = bar(v_BarPlot);
    hold on
    set(b, 'FaceAlpha', 0.2);
    b.FaceColor = 'flat';
    b.LineWidth = 0.8;
    b.CData(1,:) = [0 0 1];
    b.CData(2,:) = [0 0 1];
    b.CData(3,:) = [0 0 1];
    b.CData(4,:) = [0 0 1];
    b.CData(5,:) = [0 0 1];
    b.CData(6,:) = [0 0 1];
    b.CData(7,:) = [0 0 1];
    b.CData(8,:) = [0 0 1];
    b.CData(9,:) = [0 0 1];
    b.CData(10,:) = [0 0 1];
    b.CData(11,:) = [1 0 1];
    b.CData(12,:) = [1 0 1];
    b.CData(13,:) = [1 0 1];
    b.CData(14,:) = [1 0 1];
    b.CData(15,:) = [1 0 1];
    b.CData(16,:) = [1 0 1];
    b.CData(17,:) = [1 0 1];
    b.CData(18,:) = [1 0 1];
    b.CData(19,:) = [1 0 1];
    b.CData(20,:) = [1 0 1];
    b.CData(21,:) = [1 0 0];
    b.CData(22,:) = [1 0 0];
    b.CData(23,:) = [1 0 0];
    errorbar(v_BarPlot,v_Erro,'.k','LineWidth',0.8,'Color',[0.4,0.4,0.4])
    ylabel('mean norm feature')
    xlabel('bins')

    s_LI = 0.6;
    s_LS = 1.4;

    % BU
    for z=1:10
        v_DataPlot = stru_Joint(z).BU;
        v_X = linspace(s_LI,s_LS,numel(v_DataPlot));
        plot(v_X,v_DataPlot,'.b')

        s_LI = s_LI+1;
        s_LS = s_LS+1;
    end

    % SS
    for z=1:10
        v_DataPlot = stru_Joint(z).SS;
        v_X = linspace(s_LI,s_LS,numel(v_DataPlot));
        plot(v_X,v_DataPlot,'.m')

        s_LI = s_LI+1;
        s_LS = s_LS+1;
    end

    % TG
    for z=1:3
        v_DataPlot = stru_Joint(z).TG;
        v_X = linspace(s_LI,s_LS,numel(v_DataPlot));
        plot(v_X,v_DataPlot,'.r')

        s_LI = s_LI+1;
        s_LS = s_LS+1;
    end
    ylim(v_Lims)

end

%% Ratios

%[v_BarHFO,v_BarNoHFO] = f_Count_HFO_Periods(stru_MergData);
[v_BarHFO,v_BarNoHFO] = f_Count_HFO_Periods2(stru_MergData);

%%
[m_BarHFO] = f_Count_HFO_Periods3 (stru_MergData,[10,10,3]);

m_BarHFO(m_BarHFO==0)=NaN;

figure()
bar(mean(m_BarHFO,'omitnan'))

m_BarHFO(isnan(m_BarHFO))=0;
figure()
bar(mean(m_BarHFO),'k')
title(['Ratio num PID_{' 'HFO' '} / num PID']);



%%

[m_BarHFO] = f_Count_HFO_Periods4 (stru_MergData,23);
m_BarHFO(m_BarHFO==0)=NaN;
figure()
bar(mean(m_BarHFO,'omitnan'))

m_BarHFO(isnan(m_BarHFO))=0;
figure()
b = bar(mean(m_BarHFO),'k')
title(['Ratio num PID_{' 'HFO' '} / num PID']);
hold on
b.FaceColor = 'flat';
b.LineWidth = 0.8;
b.CData(1,:) = [0 0 1];
b.CData(2,:) = [0 0 1];
b.CData(3,:) = [0 0 1];
b.CData(4,:) = [0 0 1];
b.CData(5,:) = [0 0 1];
b.CData(6,:) = [0 0 1];
b.CData(7,:) = [0 0 1];
b.CData(8,:) = [0 0 1];
b.CData(9,:) = [0 0 1];
b.CData(10,:) = [0 0 1];
b.CData(11,:) = [1 0 1];
b.CData(12,:) = [1 0 1];
b.CData(13,:) = [1 0 1];
b.CData(14,:) = [1 0 1];
b.CData(15,:) = [1 0 1];
b.CData(16,:) = [1 0 1];
b.CData(17,:) = [1 0 1];
b.CData(18,:) = [1 0 1];
b.CData(19,:) = [1 0 1];
b.CData(20,:) = [1 0 1];
b.CData(21,:) = [1 0 0];
b.CData(22,:) = [1 0 0];
b.CData(23,:) = [1 0 0];

%% 

figure('Position',[966	672	1170 484])
subplot(1,3,1)
b = bar(v_BarHFO);
hold on
% b.FaceColor = 'flat';
% b.LineWidth = 0.8;
% b.CData(1,:) = [0 0 1];
% b.CData(2,:) = [0 0 1];
% b.CData(3,:) = [0 0 1];
% b.CData(4,:) = [0 0 1];
% b.CData(5,:) = [0 0 1];
% b.CData(6,:) = [0 0 1];
% b.CData(7,:) = [0 0 1];
% b.CData(8,:) = [0 0 1];
% b.CData(9,:) = [0 0 1];
% b.CData(10,:) = [0 0 1];
% b.CData(11,:) = [1 0 1];
% b.CData(12,:) = [1 0 1];
% b.CData(13,:) = [1 0 1];
% b.CData(14,:) = [1 0 1];
% b.CData(15,:) = [1 0 1];
% b.CData(16,:) = [1 0 1];
% b.CData(17,:) = [1 0 1];
% b.CData(18,:) = [1 0 1];
% b.CData(19,:) = [1 0 1];
% b.CData(20,:) = [1 0 1];
% b.CData(21,:) = [1 0 0];
% b.CData(22,:) = [1 0 0];
% b.CData(23,:) = [1 0 0];
title('HFO')

subplot(1,3,2)
b = bar(v_BarNoHFO);
hold on
% b.FaceColor = 'flat';
% b.LineWidth = 0.8;
% b.CData(1,:) = [0 0 1];
% b.CData(2,:) = [0 0 1];
% b.CData(3,:) = [0 0 1];
% b.CData(4,:) = [0 0 1];
% b.CData(5,:) = [0 0 1];
% b.CData(6,:) = [0 0 1];
% b.CData(7,:) = [0 0 1];
% b.CData(8,:) = [0 0 1];
% b.CData(9,:) = [0 0 1];
% b.CData(10,:) = [0 0 1];
% b.CData(11,:) = [1 0 1];
% b.CData(12,:) = [1 0 1];
% b.CData(13,:) = [1 0 1];
% b.CData(14,:) = [1 0 1];
% b.CData(15,:) = [1 0 1];
% b.CData(16,:) = [1 0 1];
% b.CData(17,:) = [1 0 1];
% b.CData(18,:) = [1 0 1];
% b.CData(19,:) = [1 0 1];
% b.CData(20,:) = [1 0 1];
% b.CData(21,:) = [1 0 0];
% b.CData(22,:) = [1 0 0];
% b.CData(23,:) = [1 0 0];
title('No HFO')

subplot(1,3,3)
b = bar(v_BarHFO./v_BarNoHFO);
hold on
% b.FaceColor = 'flat';
% b.LineWidth = 0.8;
% b.CData(1,:) = [0 0 1];
% b.CData(2,:) = [0 0 1];
% b.CData(3,:) = [0 0 1];
% b.CData(4,:) = [0 0 1];
% b.CData(5,:) = [0 0 1];
% b.CData(6,:) = [0 0 1];
% b.CData(7,:) = [0 0 1];
% b.CData(8,:) = [0 0 1];
% b.CData(9,:) = [0 0 1];
% b.CData(10,:) = [0 0 1];
% b.CData(11,:) = [1 0 1];
% b.CData(12,:) = [1 0 1];
% b.CData(13,:) = [1 0 1];
% b.CData(14,:) = [1 0 1];
% b.CData(15,:) = [1 0 1];
% b.CData(16,:) = [1 0 1];
% b.CData(17,:) = [1 0 1];
% b.CData(18,:) = [1 0 1];
% b.CData(19,:) = [1 0 1];
% b.CData(20,:) = [1 0 1];
% b.CData(21,:) = [1 0 0];
% b.CData(22,:) = [1 0 0];
% b.CData(23,:) = [1 0 0];
title('Ratio HFO over No HFO')
