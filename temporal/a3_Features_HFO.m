%% Cleaning
clear; close all; clc;

%% Loading

load('HFO.mat')
load('Features_HFO.mat')

%% Compute HFO amplitude and duration

str_Data_Path = 'C:\Users\david.henao\Desktop\All_Data_Correc\Data\';

% Fstop1 = 80;                                                      % First Stopband Frequency
% Fstop2 = 550;                                                      % Second Stopband Frequency
% N      = 70;
% Astop  = 80;
% 
% h  = fdesign.bandpass('N,Fst1,Fst2,Ast', N, Fstop1, Fstop2, Astop, 10000);
% fil_Spec = design(h, 'cheby2');
% 
% fil = f_GetIIRFilter(10000,[0.1,40]);

for i=1:numel(stru_MergData)

    str_Slice = stru_MergData(i).Slice;
    s_Elec = stru_MergData(i).Electrode;

    str_Load = strcat(str_Data_Path,str_Slice,'\E',num2str(s_Elec),'.mat');
    load(str_Load,'v_RawData','s_SampRate')

%     v_Search = filter(fil_Spec,v_RawData);
%     v_Search = flip(filter(fil_Spec, flip(v_Search)));
%     v_SearchEnv = abs(hilbert(v_Search));
%     v_SearchEnv = f_IIRBiFilter(v_SearchEnv,fil);

%     plot(v_RawData,'b')
%     hold on
%     plot(abs(hilbert(v_Search)),'r')
%     plot(v_SearchEnv,'m')

    v_Ini = stru_MergData(i).HFO_B;
    v_Fin = stru_MergData(i).HFO_E;

    v_AmpHFO = [];

    for j=1:numel(v_Ini)

        v_Seg = v_RawData(v_Ini(j):v_Fin(j));
        s_Amp = f_HFOAmp(v_Seg,s_SampRate,[80,550]);
%         v_Seg = v_SearchEnv(v_Ini(j):v_Fin(j));
%         s_Amp = max(v_Seg);
        v_AmpHFO(j) = s_Amp;

    end

    stru_MergFeat(i).HFO_A = v_AmpHFO;
    stru_MergFeat(i).HFO_D = stru_MergData(i).HFO_E-stru_MergData(i).HFO_B;
    stru_MergFeat(i).HFO_F = stru_MergData(i).HFO_F; 

    % For stats

    v_Axis = stru_MergData(i).HFO_B;
    v_Axis = (v_Axis-1)/(stru_MergData(i).Norm_max-1);

    [v_AStats] = f_DivideBinsStats (v_AmpHFO,v_Axis,23);
    [v_DStats] = f_DivideBinsStats (stru_MergData(i).HFO_E-stru_MergData(i).HFO_B,v_Axis,23);
    [v_FStats] = f_DivideBinsStats (stru_MergData(i).HFO_F,v_Axis,23);

    m_StatsA(i,:) = v_AStats;
    m_StatsD(i,:) = v_DStats;
    m_StatsF(i,:) = v_FStats;
    i

end

%% Points pooled

v_A_Bag=[];
v_F_Bag=[];

str_Feature = 'HFO frequency';
str_FeatureBar = ' Bins HFO frequency';

for i=1:numel(stru_MergFeat)

    v_Feat = stru_MergFeat(i).HFO_F;
    %v_Feat = (v_Feat/s_SampRate)*1000;
    %v_Feat = (v_Feat-min(v_Feat))/(max(v_Feat)-min(v_Feat));
    v_Axis = stru_MergData(i).HFO_B;
  
    %v_Axis = (v_Axis-min(v_Axis))/(max(v_Axis)-min(v_Axis));
    v_Axis = (v_Axis-1)/(stru_MergData(i).Norm_max-1);
    %v_Feat = (v_Feat-min(v_Feat))/(max(v_Feat)-min(v_Feat));              % Norm Y
    %v_Feat = v_Feat/(max(v_Feat));

    v_A_Bag=[v_A_Bag,v_Axis];
    v_F_Bag=[v_F_Bag,v_Feat];

end

figure()
plot(v_A_Bag,v_F_Bag,'*k')
title(str_Feature)
ylabel('duration (ms)')
xlabel('norm time peer slice')
xlim([-0.1,1.1])
%ylim([-0.1,1.1])

%% R and FR
figure()
hold on
conR = 0;
conFR = 0;
for i=1:numel(v_F_Bag)
    if v_F_Bag(i)<250
        plot(v_A_Bag(i),v_F_Bag(i),'*b')
        conR = conR +1;
    else
        plot(v_A_Bag(i),v_F_Bag(i),'*r')
        conFR = conFR +1;
    end
end
title(str_Feature)

figure()
b = bar([conR,conFR]);
set(gca,'xticklabel',{'Riples', 'Fast Ripples'})
ylabel('Number events')
b.FaceColor = 'flat';
b.CData(1,:) = [0 0 1];
b.CData(2,:) = [1 0 0];



%% Bar plot

[v_A_Bag,s_IndxSort]=sort(v_A_Bag);
v_F_Bag = v_F_Bag(s_IndxSort);

s_NumBar = 15;
v_Div = linspace(0,1,s_NumBar+1);
v_Bar = [];
v_Err = [];
for j=1:numel(v_Div)-1
    s_Inf = v_Div(j);
    s_Sup = v_Div(j+1);

    v_Bol = v_A_Bag>=s_Inf & v_A_Bag<s_Sup;
    v_Bar(j) = mean(v_F_Bag(v_Bol));
    v_Err(j) = std(v_F_Bag(v_Bol));
end

figure()
b1 = bar(v_Bar,'k');
set(b1,'FaceAlpha',0.5)
title(str_FeatureBar)
xlabel('bins')
hold on
errorbar(v_Bar,v_Err,'.k','LineWidth',2)
ylabel('mean HFO duration')
xlabel('bins')

%%

x = linspace(0,1,15);
y = v_Bar;

figure('Position',[1434 336 968 818])
plot(v_A_Bag,v_F_Bag,'.k')
hold on
title(str_Feature)
%xlim([-0.1,3.1])
%ylim([-0.1,1.1])

b = bar(x,y,'k');
set(b, 'FaceAlpha', 0.2);
errorbar(x,y,v_Err,'.k','LineWidth',1.5)
ylabel('HFO frequency')
xlabel('normalized time peer slice')



%% Stats
[~,~,p_Val] = f_FriedmanTest(mean(m_StatsD),0.05)

%% Num events in time

s_NumBar = 15;
v_Div = linspace(0,1,s_NumBar+1);
v_Bar = zeros(1,s_NumBar);

for i=1:numel(stru_MergData)

    v_Feat = stru_MergData(i).HFO_B;
    v_Feat = (v_Feat-1)./(stru_MergData(i).Norm_max-1);

    v_Cont = 0;

    for j=1:numel(v_Div)-1
        s_Inf = v_Div(j);
        s_Sup = v_Div(j+1);

        v_Bol = v_Feat>=s_Inf & v_Feat<s_Sup;
        v_Cont(j) = sum(v_Bol); 
    end

    v_Bar = v_Bar+ v_Cont;

end

figure()
bar(v_Bar,'k')
title('Number of HFO in time')
xlabel('bins')
ylabel(strcat('n =',{' '},num2str(sum(v_Bar))))