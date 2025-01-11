%% Cleaning
clear; close all; clc;

%% Loading

load('PID_HFA.mat')

%% Compute PID_A, PID_D, PID_Slope and PID_IEF

str_Data_Path = './Data/';
s_SampRate = 10000;

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
        [s_Max,s_IndMax] = max(v_Seg);

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

%% Points pooled

v_B_Bag=[];
v_S_Bag=[];
v_T_Bag=[];

v_B_A_Bag=[];
v_S_A_Bag=[];
v_T_A_Bag=[];

str_Feature = 'norm PID duration';
str_FeatureBar = ' Bins norm PID duration';

for i=1:numel(stru_MergFeat)

    v_Feat = stru_MergFeat(i).PID_A;
    v_Feat = (v_Feat-min(v_Feat))./(max(v_Feat)-min(v_Feat));
    %v_Feat = (v_Feat-min(v_Feat))./(max(v_Feat)-min(v_Feat));
    %v_Feat = v_Feat/max(v_Feat);
    v_Axis = stru_MergData(i).PID_B;
    %v_Axis(1)=[]; % For IET

    s_S = stru_MergData(i).SS;
    s_T = stru_MergData(i).TG;

    % Build up

    v_Sel = v_Axis<s_S;

    v_B_Ax = v_Axis(v_Sel);
    v_B_Ft = v_Feat(v_Sel);

    v_B_Ax = (v_B_Ax-min(v_B_Ax))/(max(v_B_Ax)-min(v_B_Ax));
    %v_B_Ft = (v_B_Ft-min(v_B_Ft))/(max(v_B_Ft)-min(v_B_Ft));              % Norm Y
    %v_B_Ft = v_B_Ft/max(v_B_Ft);
    s_MeanBU = mean(v_B_Ft);

    % Steady state

    v_Sel = v_Axis>=s_S & v_Axis<s_T;

    v_S_Ax = v_Axis(v_Sel);
    v_S_Ft = v_Feat(v_Sel);

    v_S_Ax = (v_S_Ax-min(v_S_Ax))/(max(v_S_Ax)-min(v_S_Ax));
    %v_S_Ft = (v_S_Ft-min(v_S_Ft))/(max(v_S_Ft)-min(v_S_Ft));              % Norm Y
    %v_S_Ft = v_S_Ft/max(v_S_Ft);
    s_MeanSS = mean(v_S_Ft);

    %Trigger

    v_Sel = v_Axis>=s_T;

    v_T_Ax = v_Axis(v_Sel);
    v_T_Ft = v_Feat(v_Sel);

    v_T_Ax = (v_T_Ax-min(v_T_Ax))/(max(v_T_Ax)-min(v_T_Ax));
    %v_T_Ft = (v_T_Ft-min(v_T_Ft))/(max(v_T_Ft)-min(v_T_Ft));              % Norm Y
    %v_T_Ft = v_T_Ft/max(v_T_Ft);
    s_MeanTG = mean(v_T_Ft);

    
    v_B_A_Bag=[v_B_A_Bag,v_B_Ax];
    v_S_A_Bag=[v_S_A_Bag,v_S_Ax];
    v_T_A_Bag=[v_T_A_Bag,v_T_Ax];    
    
    v_B_Bag=[v_B_Bag,v_B_Ft];
    v_S_Bag=[v_S_Bag,v_S_Ft];
    v_T_Bag=[v_T_Bag,v_T_Ft];

    m_Stats(i,1) = s_MeanBU;
    m_Stats(i,2) = s_MeanSS;
    m_Stats(i,3) = s_MeanTG;

end

figure()
plot(v_B_A_Bag,v_B_Bag,'*b')
hold on
plot(v_S_A_Bag+1,v_S_Bag,'*m')
plot(v_T_A_Bag+2,v_T_Bag,'*r')
title(str_Feature)
%xlim([-0.1,3.1])
%ylim([-0.1,1.1])
title(str_Feature)
ylabel('IEF (Hz)')
xlabel('norm time peer period')

% figure()
% plot(v_B_A_Bag,(v_B_Bag-mean(v_B_Bag))/std(v_B_Bag),'*b')
% hold on
% plot(v_S_A_Bag+1,(v_S_Bag-mean(v_S_Bag))/std(v_S_Bag),'*m')
% plot(v_T_A_Bag+2,(v_T_Bag-mean(v_T_Bag))/std(v_T_Bag),'*r')
% title(str_Feature)

%% Bar plot

s_Size_B = floor(numel(v_B_A_Bag)/10);
s_Size_S = floor(numel(v_S_A_Bag)/10);
s_Size_T = floor(numel(v_T_A_Bag)/3);

% Build up bar

[~,s_IndxSort]=sort(v_B_A_Bag);
v_Use = v_B_Bag(s_IndxSort);

s_Inf = 1;

for i=1:10

    s_Sup = s_Inf+s_Size_B;

    try
        v_Temp = v_Use(s_Inf:s_Sup);
    catch
        v_Temp = v_Use(s_Inf:numel(v_Use));
    end
    v_Temp(v_Temp==Inf)=[];
    v_Mean_B(i) = mean(v_Temp);
    v_STD_B(i) = std(v_Temp);
    %v_STD_B(i) = std(v_Temp)/sqrt(numel(v_Temp));

    stru_Joint(i).BU = v_Temp;
    
    s_Inf = s_Sup+1;

end

% Steady bar

[~,s_IndxSort]=sort(v_S_A_Bag);
v_Use = v_S_Bag(s_IndxSort);

s_Inf = 1;

for i=1:10

    s_Sup = s_Inf+s_Size_S;

    try
        v_Temp = v_Use(s_Inf:s_Sup);
    catch
        v_Temp = v_Use(s_Inf:numel(v_Use));
    end
    v_Temp(v_Temp==Inf)=[];
    v_Mean_S(i) = mean(v_Temp);
    v_STD_S(i) = std(v_Temp);
    %v_STD_S(i) = std(v_Temp)/sqrt(numel(v_Temp));
    stru_Joint(i).SS = v_Temp;
    
    s_Inf = s_Sup+1;
    
end

% Trigger

[~,s_IndxSort]=sort(v_T_A_Bag);
v_Use = v_T_Bag(s_IndxSort);

s_Inf = 1;

for i=1:3

    s_Sup = s_Inf+s_Size_T;

    try
        v_Temp = v_Use(s_Inf:s_Sup);
    catch
        v_Temp = v_Use(s_Inf:numel(v_Use));
    end
    v_Temp(v_Temp==Inf)=[];
    v_Mean_T(i) = mean(v_Temp);
    v_STD_T(i) = std(v_Temp);
    %v_STD_T(i) = std(v_Temp)/sqrt(numel(v_Temp));
    stru_Joint(i).TG = v_Temp;
    s_Inf = s_Sup+1;
    
end


v_Plot = [v_Mean_B,v_Mean_S,v_Mean_T];
%v_Plot = v_Plot./10000;
v_Erro = [v_STD_B,v_STD_S,v_STD_T];

figure()
b = bar(v_Plot);
b.FaceColor = 'flat';
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

hold on
errorbar(v_Plot,v_Erro,'.k','LineWidth',2)
title(str_FeatureBar)
xlabel('bins')
ylabel('IEF (Hz)')

%% Both charts toguether

x = [linspace(0.1,0.9,10),linspace(1.1,1.9,10),linspace(2.1,2.9,3)];
y = v_Plot;

figure('Position',[1434 336 968 818])
plot(v_B_A_Bag,v_B_Bag,'.b')
hold on
plot(v_S_A_Bag+1,v_S_Bag,'.m')
plot(v_T_A_Bag+2,v_T_Bag,'.r')
title(str_Feature)
xlim([-0.1,3.1])
ylim([-0.1,1.1])

b = bar(x,v_Plot);
set(b, 'FaceAlpha', 0.2);
b.FaceColor = 'flat';
b.LineWidth = 1.5;
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

errorbar(x,y,v_Erro,'.k','LineWidth',1.5)

ylabel('norm slope')
xlabel('norm time peer period')

%% Both charts toguether ver 2

figure('Position',[1434 336 968 818])
b = bar(v_Plot);
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
errorbar(y,v_Erro,'.k','LineWidth',0.8,'Color',[0.4,0.4,0.4])
ylabel('norm amplitude')
xlabel('norm time peer period')

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

title(str_Feature)
ylim([0,1.1])

%% Stats
[~,~,p_Val] = f_FriedmanTest(m_Stats,0.05)

%% Bar plot num events

s_NumBar = 25;
v_Div = linspace(0,1,s_NumBar+1);
v_Bar = zeros(1,s_NumBar);

for i=1:numel(stru_MergData)    
    v_Feat = stru_MergData(i).PID_B;
    %v_Feat = (v_Feat-min(v_Feat))./(max(v_Feat)-min(v_Feat));
    v_Feat = (v_Feat-1)./(stru_MergData(i).N_Samp-1);

    v_Cont = 0;

    for j=1:numel(v_Div)-1
        s_Inf = v_Div(j);
        s_Sup = v_Div(j+1);

        v_Bol = v_Feat>=s_Inf & v_Feat<s_Sup;
        v_Cont(j) = sum(v_Bol); 
    end

    v_Bar = v_Bar+ v_Cont;

end
bar(v_Bar,'k')
title('Number of PID in time')
xlabel('bins')
ylabel(strcat('n =',{' '},num2str(sum(v_Bar))))