%% Cleaning
clear; close all; clc;

%% Loading

load('HFO_Feat_BST.mat')

%% Points pooled and bars (matrix for stats and charts)

s_Norm = 0;
s_Bin = 15;
v_All_Feat = [];
v_All_Feat_Lock = [];

for i=1:numel(stru_MergFeat)

    % Features %
    v_Feat = stru_MergFeat(i).HFO_A;                                       % SE CAMBIA FEAT
    v_Feat_Lock = stru_MergFeat(i).HFO_D;

    [~,c]= max(v_Feat_Lock);

    v_Feat(c)=[];
    v_Feat_Lock(c)=[];

    if s_Norm == 1
        v_Feat = (v_Feat-min(v_Feat))./(max(v_Feat)-min(v_Feat));        
    end

    v_Feat_Lock = (v_Feat_Lock-min(v_Feat_Lock))./(max(v_Feat_Lock)-min(v_Feat_Lock));

     % % Bining %
 
    v_LinSpa = linspace(0,1,s_Bin+1);

    for j=1:numel(v_LinSpa)-1

        s_LimI = v_LinSpa(j);
        s_LimS = v_LinSpa(j+1);

        if j == numel(v_LinSpa)-1
            v_Eval = (s_LimI<=v_Feat_Lock) & (v_Feat_Lock<=s_LimS);
        else
            v_Eval = (s_LimI<=v_Feat_Lock) & (v_Feat_Lock<s_LimS);
        end

        m_mean(i,j) = mean(v_Feat(v_Eval));
        stru_Data(i,j).Data = v_Feat(v_Eval);
        stru_Data(i,j).Axis = v_Feat_Lock(v_Eval);

        v_All_Feat = [v_All_Feat,v_Feat];
        v_All_Feat_Lock = [v_All_Feat_Lock,v_Feat_Lock];

    end  
end

v_Color = [3 167 187]./255;
s_Sz = 13;

%% Figure all points
figure('Position',[1434 336 968 818])
plot(v_All_Feat_Lock,v_All_Feat,'*r')
ylabel('HFO amplitude','FontSize',s_Sz)
xlabel('HFO duration','FontSize',s_Sz)
title('HFO duration vs amplitude','FontSize',s_Sz)

%% Join plot with bars and pooled points

v_Plot = [mean(m_mean,'omitnan')];

figure('Position',[1434 336 968 818])
b = bar(v_Plot);
hold on
set(b, 'FaceAlpha', 0.2);
b.FaceColor = 'flat';
b.LineWidth = 0.8;

for i=1:numel(v_Plot)

    b.CData(i,:) = v_Color;

    for j=1:size(stru_Data,1)
        v_Y = stru_Data(j,i).Data;
        v_X = linspace(i-0.4,i+0.4,numel(v_Y));
        plot(v_X,v_Y,'.','MarkerEdgeColor',v_Color,'MarkerFaceColor',v_Color)
    end

end

v_EBar = [std(m_mean,'omitmissing')];

errorbar(v_Plot,v_EBar,'.k','LineWidth',0.8,'Color',[0.4,0.4,0.4])
ylabel('mean HFO amplitude','FontSize',s_Sz)
xlabel('pooled data in bins peer HFO duration','FontSize',s_Sz)
title('HFO duration vs amplitude','FontSize',s_Sz)
set(gca,'FontSize',s_Sz)

%% Delete NaN rows (only for stats)

v_Del = isnan(mean(m_mean,2));
m_mean(v_Del,:)=[];
stru_Data(v_Del,:)=[];

%% Stats

[p_b,~,stats] = friedman(m_mean);
figure()
c_b = multcompare(stats,'CriticalValueType','dunn-sidak');
title('Build-up groups')

f_ImageMultiComp(c_b,0.05)
%title('Multicomparison test dunn-sidak','FontSize',s_Sz')
set(gca,'FontSize',s_Sz)

%% Quantifications absolute values
close all

m_Quan(1,:) = mean(m_mean);
m_Quan(2,:) = std(m_mean);
m_Quan(3,:) = min(m_mean);
m_Quan(4,:) = max(m_mean);
size(m_mean,1)