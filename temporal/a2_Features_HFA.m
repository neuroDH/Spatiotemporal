%% Cleaning
clear; close all; clc;

%% Loading
load('PID_HFA.mat')

%% Compute HFA frequency and num events bns

v_B_contT = zeros(1,10);
v_S_contT = zeros(1,10);
v_T_contT = zeros(1,3);

str_Data_Path = './Data/';
s_SampRate = 10000;
N      = 70;   % Order
Fstop1 = 100;  % First Stopband Frequency
Fstop2 = 600;  % Second Stopband Frequency
Astop  = 80;   % Stopband Attenuation (dB)

h  = fdesign.bandpass('N,Fst1,Fst2,Ast', N, Fstop1, Fstop2, Astop, s_SampRate);
Hd = design(h, 'cheby2');

for i=1:numel(stru_MergData)

    str_Slice = stru_MergData(i).Slice;
    
    str_Load = strcat(str_Data_Path,str_Slice,'.mat');
    load(str_Load,'v_RawData','v_FilData')

    v_Ini = stru_MergData(i).HFA_B;
    v_Fin = stru_MergData(i).HFA_E;

    % HFA filtered

    v_FilHFA = filter(Hd,v_RawData);
    v_FilHFA = flip(filter(Hd, flip(v_FilHFA)));
    v_FilHFA = abs(hilbert(v_FilHFA));

    % Main freq and HFA amplitude

    v_FreqHFA = [];
    v_HFAAmp = [];
    v_PeakIndx = [];

    for j=1:numel(v_Ini)
        
        v_Seg = v_RawData(v_Ini(j):v_Fin(j));
        v_Seg2 = v_FilData(v_Ini(j):v_Fin(j));
        [~,s_IndMax] = max(v_Seg2);
        s_Freq = f_PreFourier(v_Seg,s_SampRate,[180,550]);
        v_FreqHFA(j) = s_Freq;
        v_HFAAmp(j) = max(v_FilHFA(v_Ini(j):v_Fin(j)));
        v_PeakIndx(j) = v_Ini(j)+s_IndMax;
    end

    stru_MergFeat(i).HFA_A = v_HFAAmp;
    stru_MergFeat(i).HFA_D = (v_Fin-v_Ini)./s_SampRate;
    stru_MergFeat(i).HFA_IEF = 1./(diff(v_PeakIndx)./s_SampRate);  
    stru_MergFeat(i).HFA_F = v_FreqHFA;

    % Num HFA in each period
    v_Event = stru_MergData(i).HFA_B;
    s_SS = stru_MergData(i).SS;
    s_TG = stru_MergData(i).TG;
    s_End = stru_MergData(2).SO;
    
    [v_B_cont,v_S_cont,v_T_cont] = f_NumEvent (v_Event,s_SS,s_TG,s_End);
    stru_MergFeat(i).HFA_NE = [v_B_cont,v_S_cont,v_T_cont];

    v_B_contT = v_B_contT+v_B_cont;
    v_S_contT = v_S_contT+v_S_cont;
    v_T_contT = v_T_contT+v_T_cont;
end

b = bar([v_B_contT,v_S_contT,v_T_contT]);

%% Points pooled

v_B_Bag=[];
v_S_Bag=[];
v_T_Bag=[];

v_B_A_Bag=[];
v_S_A_Bag=[];
v_T_A_Bag=[];

str_Feature = 'HFA norm amplitude';
str_FeatureBar = ' Bins HFA norm amplitude';

for i=1:numel(stru_MergFeat)

    v_Feat = stru_MergFeat(i).HFA_A;
    v_Feat = (v_Feat-min(v_Feat))./(max(v_Feat)-min(v_Feat));
    v_Axis = stru_MergData(i).HFA_B;
    v_Axis(1)=[]; % For IET

    s_S = stru_MergData(i).SS;
    s_T = stru_MergData(i).TG;

    % Build up

    v_Sel = v_Axis<s_S;

    v_B_Ax = v_Axis(v_Sel);
    v_B_Ft = v_Feat(v_Sel);

    v_B_Ax = (v_B_Ax-min(v_B_Ax))/(max(v_B_Ax)-min(v_B_Ax));
    %v_B_Ft = (v_B_Ft-min(v_B_Ft))/(max(v_B_Ft)-min(v_B_Ft));              % Norm Y
    s_MeanBU = mean(v_B_Ft);

    % Steady state

    v_Sel = v_Axis>=s_S & v_Axis<s_T;

    v_S_Ax = v_Axis(v_Sel);
    v_S_Ft = v_Feat(v_Sel);

    v_S_Ax = (v_S_Ax-min(v_S_Ax))/(max(v_S_Ax)-min(v_S_Ax));
    %v_S_Ft = (v_S_Ft-min(v_S_Ft))/(max(v_S_Ft)-min(v_S_Ft));              % Norm Y
    s_MeanSS = mean(v_S_Ft);

    %Trigger

    v_Sel = v_Axis>=s_T;

    v_T_Ax = v_Axis(v_Sel);
    v_T_Ft = v_Feat(v_Sel);

    v_T_Ax = (v_T_Ax-min(v_T_Ax))/(max(v_T_Ax)-min(v_T_Ax));
    %v_T_Ft = (v_T_Ft-min(v_T_Ft))/(max(v_T_Ft)-min(v_T_Ft));              % Norm Y
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
xlim([-0.1,3.1])
%ylim([-0.1,2.5])
ylabel('IEF frequency (Hz)')
xlabel('norm time peer period')

% v_B_A_Bag(v_B_Bag>4)=[];
% v_B_Bag(v_B_Bag>4)=[];
% 
% v_S_A_Bag(v_S_Bag>4)=[];
% v_S_Bag(v_S_Bag>4)=[];
% 
% v_T_A_Bag(v_T_Bag>4)=[];
% v_T_Bag(v_T_Bag>4)=[];

%% Bar plot

s_Size_B = floor(numel(v_B_A_Bag)/10);
s_Size_S = floor(numel(v_S_A_Bag)/10);
s_Size_T = floor(numel(v_T_A_Bag)/3);

% Build up bar

[~,s_IndxSort]=sort(v_B_A_Bag);
v_Use = v_B_Bag(s_IndxSort);

s_Inf = 1;

m_StatsIn_B = [];

for i=1:10

    s_Sup = s_Inf+s_Size_B;

    try
        v_Temp = v_Use(s_Inf:s_Sup);
    catch
        v_Temp = v_Use(s_Inf:numel(v_Use));
    end
    v_Temp(v_Temp==Inf)=[];
    v_Mean_B(i) = mean(v_Temp);
    v_Numel_B(i) = numel(v_Temp);
    v_STD_B(i) = std(v_Temp);
    %v_STD_B(i) = std(v_Temp)/sqrt(numel(v_Temp));
    stru_Joint(i).BU = v_Temp;
    
    s_Inf = s_Sup+1;

    try
        m_StatsIn_B(:,i) = v_Temp;
    catch
        s_Si = size(m_StatsIn_B,1);
        m_StatsIn_B(:,i) = [v_Temp,nan(1,s_Si-numel(v_Temp))];
    end

end

% Steady bar

[~,s_IndxSort]=sort(v_S_A_Bag);
v_Use = v_S_Bag(s_IndxSort);

s_Inf = 1;

m_StatsIn_S =[];

for i=1:10

    s_Sup = s_Inf+s_Size_S;

    try
        v_Temp = v_Use(s_Inf:s_Sup);
    catch
        v_Temp = v_Use(s_Inf:numel(v_Use));
    end
    v_Temp(v_Temp==Inf)=[];
    v_Mean_S(i) = mean(v_Temp);
    v_Numel_S(i) = numel(v_Temp);
    v_STD_S(i) = std(v_Temp);
    %v_STD_S(i) = std(v_Temp)/sqrt(numel(v_Temp));
    stru_Joint(i).SS = v_Temp;
    
    s_Inf = s_Sup+1;

    try
        m_StatsIn_S(:,i) = v_Temp;
    catch
        s_Si = size(m_StatsIn_S,1);
        m_StatsIn_S(:,i) = [v_Temp,nan(1,s_Si-numel(v_Temp))];
    end

    
end

% Trigger

[~,s_IndxSort]=sort(v_T_A_Bag);
v_Use = v_T_Bag(s_IndxSort);

s_Inf = 1;

m_StatsIn_T=[];

for i=1:3

    s_Sup = s_Inf+s_Size_T;

    try
        v_Temp = v_Use(s_Inf:s_Sup);
    catch
        v_Temp = v_Use(s_Inf:numel(v_Use));
    end
    v_Temp(v_Temp==Inf)=[];
    v_Mean_T(i) = mean(v_Temp);
    v_Numel_T(i) = numel(v_Temp);
    v_STD_T(i) = std(v_Temp);

    %v_STD_T(i) = std(v_Temp)/sqrt(numel(v_Temp));
    stru_Joint(i).TG = v_Temp;
    
    s_Inf = s_Sup+1;

    try
        m_StatsIn_T(:,i) = v_Temp;
    catch
        s_Si = size(m_StatsIn_T,1);
        m_StatsIn_T(:,i) = [v_Temp,nan(1,s_Si-numel(v_Temp))];
    end

end


v_Plot = [v_Mean_B,v_Mean_S,v_Mean_T];
%v_Plot = [v_Numel_B,v_Numel_S,v_Numel_T];
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
errorbar(v_Plot,v_Erro,'.k','LineWidth',0.8,'Color',[0.1,0.1,0.1])
title(str_FeatureBar)
xlabel('bins')
ylabel('IEF frequency')

load ('ForStats.mat','stru_Stats')

stru_Stats.HFA(1).IEF = m_StatsIn_B;
stru_Stats.HFA(2).IEF = m_StatsIn_S;
stru_Stats.HFA(3).IEF = m_StatsIn_T;

save('ForStats.mat','stru_Stats')

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
%ylim([-0.1,1.1])

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

errorbar(x,y,v_Erro,'.k','LineWidth',0.8,'Color',[0.1,0.1,0.1])

ylabel('IEF frequency')
xlabel('norm time peer period')

%% Both charts toguether ver 2

s_Sz = 13;

figure('Position',[1434 336 968 818])
%figure()
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
errorbar(y,v_Erro,'.k','LineWidth',0.8,'Color',[0.1,0.1,0.1])
ylabel('mean norm amplitude','FontSize',s_Sz)
xlabel('pooled data - bins peer subperiods','FontSize',s_Sz)
title(str_Feature,'FontSize',s_Sz)
set(gca,'FontSize',s_Sz)

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


%ylim([0,1.1])

%% Stats
[~,~,p_Val] = f_FriedmanTest(m_Stats,0.05)

%%
s_NumBar = 25;
v_Div = linspace(0,1,s_NumBar+1);
v_Bar = zeros(1,s_NumBar);

for i=1:numel(stru_MergData)    
    v_Feat = stru_MergData(i).HFA_B;
    %v_Feat = (v_Feat-min(v_Feat))./(max(v_Feat)-min(v_Feat));
    v_Feat = (v_Feat-1)./(stru_MergData(i).SO-1);

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
title('Number of HFA in time')
xlabel('bins')
ylabel(strcat('n =',{' '},num2str(sum(v_Bar))))