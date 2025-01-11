%% Cleaning
clear; close all; clc;

%% Loading

load('HFO_BST.mat')
load('HFO_Feat_BST.mat')

%% Points pooled

v_B_Bag=[];
v_S_Bag=[];
v_T_Bag=[];

v_B_A_Bag=[];
v_S_A_Bag=[];
v_T_A_Bag=[];

str_Feature = 'HFO frequency';
str_FeatureBar = ' Bins HFO duration';

for i=1:numel(stru_MergFeat)

    v_Feat = stru_MergFeat(i).HFO_A;
    v_Feat = (v_Feat-min(v_Feat))./(max(v_Feat)-min(v_Feat));

    v_Axis = stru_MergData(i).HFO_B;
    %v_Axis(1)=[]; % For IET

    s_S = stru_MergData(i).SS;
    s_T = stru_MergData(i).TG;

    % Build up

    v_Sel = v_Axis<s_S;

    v_B_Ax = v_Axis(v_Sel);
    v_B_Ft = v_Feat(v_Sel);

    if ~isempty(v_B_Ax)
        v_B_Ax = (v_B_Ax-min(v_B_Ax))/(max(v_B_Ax)-min(v_B_Ax));
    end

    s_MeanBU = mean(v_B_Ft);

    % Steady state

    v_Sel = v_Axis>=s_S & v_Axis<s_T;

    v_S_Ax = v_Axis(v_Sel);
    v_S_Ft = v_Feat(v_Sel);

    if ~isempty(v_S_Ax)
        v_S_Ax = (v_S_Ax-min(v_S_Ax))/(max(v_S_Ax)-min(v_S_Ax));
    end

    s_MeanSS = mean(v_S_Ft);

    %Trigger

    v_Sel = v_Axis>=s_T;

    v_T_Ax = v_Axis(v_Sel);
    v_T_Ft = v_Feat(v_Sel);

    if ~isempty(v_T_Ax)
        v_T_Ax = (v_T_Ax-min(v_T_Ax))/(max(v_T_Ax)-min(v_T_Ax));
    end



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
ylabel('norm HFO frequency')
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
m_StatsIn_B=[];

for i=1:10

    s_Sup = s_Inf+s_Size_B;

    try
        v_Temp = v_Use(s_Inf:s_Sup);
    catch
        v_Temp = v_Use(s_Inf:numel(v_Use));
    end
    v_Temp(v_Temp==Inf)=[];
    v_Mean_B(i) = mean(v_Temp);
    %v_STD_B(i) = std(v_Temp);
    v_STD_B(i) = std(v_Temp)/sqrt(numel(v_Temp));
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
m_StatsIn_S=[];

for i=1:10

    s_Sup = s_Inf+s_Size_S;

    try
        v_Temp = v_Use(s_Inf:s_Sup);
    catch
        v_Temp = v_Use(s_Inf:numel(v_Use));
    end
    v_Temp(v_Temp==Inf)=[];
    v_Mean_S(i) = mean(v_Temp);
    %v_STD_S(i) = std(v_Temp);
    v_STD_S(i) = std(v_Temp)/sqrt(numel(v_Temp));
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
    %v_STD_T(i) = std(v_Temp);
    v_STD_T(i) = std(v_Temp)/sqrt(numel(v_Temp));
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
ylabel('mean norm frequency')

% load ('ForStats.mat','stru_Stats')
% 
% stru_Stats.HFO(1).IEF = m_StatsIn_B;
% stru_Stats.HFO(2).IEF = m_StatsIn_S;
% stru_Stats.HFO(3).IEF = m_StatsIn_T;
% 
% save('ForStats.mat','stru_Stats')

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

ylabel('norm frequency')
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
ylabel('frequency')
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

title(str_Feature)
%ylim([0,1.1])

% plot(v_B_A_Bag,v_B_Bag,'.b')
% hold on
% plot(v_S_A_Bag+1,v_S_Bag,'.m')
% plot(v_T_A_Bag+2,v_T_Bag,'.r')
% title(str_Feature)
% xlim([-0.1,3.1])
% ylim([-0.1,1.1])

% plot(v_B_A_Bag,v_B_Bag,'.b')
% hold on
% plot(v_S_A_Bag+1,v_S_Bag,'.m')
% plot(v_T_A_Bag+2,v_T_Bag,'.r')
% title(str_Feature)
% xlim([-0.1,3.1])
% ylim([-0.1,1.1])


%% Stats
[~,~,p_Val] = f_FriedmanTest(m_Stats,0.05);

%% Bar plot num events

s_NumBar = 18;
v_Div = linspace(0,1,s_NumBar+1);
v_Bar = zeros(1,s_NumBar);
m_Cont = [];

for i=1:numel(stru_MergData)
    %v_Feat = stru_MergData(i).PID_B;
    v_Feat = stru_MergData(i).HFO_B;
    v_Feat = (v_Feat-min(v_Feat))./(max(v_Feat)-min(v_Feat));
    % v_Feat = (v_Feat-1)./(stru_MergData(i).N_Samp-1);

    v_Cont = 0;

    for j=1:numel(v_Div)-1
        s_Inf = v_Div(j);
        s_Sup = v_Div(j+1);

        v_Bol = v_Feat>=s_Inf & v_Feat<s_Sup;
        v_Cont(j) = sum(v_Bol);
    end

    m_Cont(i,:) = v_Cont;
    v_Bar = v_Bar+ v_Cont;

end
bar(v_Bar,'k')
title('Number of PID in time')
xlabel('bins')
ylabel(strcat('n =',{' '},num2str(sum(v_Bar))))