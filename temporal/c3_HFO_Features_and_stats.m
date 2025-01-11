%% Cleaning
clear; close all; clc;

%% Loading

load('HFO_BST.mat')
load('HFO_Feat_BST.mat')

%% Compute HFO IEF

s_SampRate = 10000;

for i=1:numel(stru_MergData)
    v_PeakIndx = stru_MergData(i).HFO_B;
    stru_MergFeat(i).HFO_IEF = 1./(diff(v_PeakIndx)./s_SampRate);

    v_Dur = (stru_MergFeat(i).HFO_D)./s_SampRate;
    stru_MergFeat(i).HFO_D = v_Dur;

end

%% Points pooled and bars (matrix for stats and charts)

s_Norm = 0;
s_BinB = 12;
s_BinS = 5;
s_BinT = 1;

for i=1:numel(stru_MergFeat)

    % Features %
    v_Feat = stru_MergFeat(i).HFO_IEF;
    
    if s_Norm == 1
        v_Feat = (v_Feat-min(v_Feat))./(max(v_Feat)-min(v_Feat));
    end
   
    v_Axis = stru_MergData(i).HFO_B;
    v_Axis(1)=[]; % For IEF

    % Features asociated to each subperiods %

    s_S = stru_MergData(i).SS;
    s_T = stru_MergData(i).TG;

    % Build up

    v_Sel = v_Axis<s_S;

    v_B_Ax = v_Axis(v_Sel);
    v_B_Ft = v_Feat(v_Sel);

    v_B_Ax = (v_B_Ax-min(v_B_Ax))/(max(v_B_Ax)-min(v_B_Ax));
   
    % Steady state

    v_Sel = v_Axis>=s_S & v_Axis<s_T;

    v_S_Ax = v_Axis(v_Sel);
    v_S_Ft = v_Feat(v_Sel);

    v_S_Ax = (v_S_Ax-min(v_S_Ax))/(max(v_S_Ax)-min(v_S_Ax));
 
    %Trigger

    v_Sel = v_Axis>=s_T;

    v_T_Ax = v_Axis(v_Sel);
    v_T_Ft = v_Feat(v_Sel);

    v_T_Ax = (v_T_Ax-min(v_T_Ax))/(max(v_T_Ax)-min(v_T_Ax));

    % Bining %

    % Build-up 

    v_LinSpa = linspace(0,1,s_BinB+1);

    for j=1:numel(v_LinSpa)-1

        s_LimI = v_LinSpa(j);
        s_LimS = v_LinSpa(j+1);

        if j == numel(v_LinSpa)-1
            v_Eval = (s_LimI<=v_B_Ax) & (v_B_Ax<=s_LimS);
        else
            v_Eval = (s_LimI<=v_B_Ax) & (v_B_Ax<s_LimS);
        end

        try
            m_mean_B(i,j) = mean(v_B_Ft(v_Eval));
            stru_Data_B(i,j).Data = v_B_Ft(v_Eval);
            stru_Data_B(i,j).Axis = v_B_Ax(v_Eval);

        catch

            m_mean_B(i,j) = NaN;
            stru_Data_B(i,j).Data = [];
            stru_Data_B(i,j).Axis = [];

        end

    end

    v_LinSpa = linspace(0,1,s_BinS+1);
    % Steady
  
    for j=1:numel(v_LinSpa)-1

        s_LimI = v_LinSpa(j);
        s_LimS = v_LinSpa(j+1);

        if j == numel(v_LinSpa)-1
            v_Eval = (s_LimI<=v_S_Ax) & (v_S_Ax<=s_LimS);
        else
            v_Eval = (s_LimI<=v_S_Ax) & (v_S_Ax<s_LimS);
        end

        try
            m_mean_S(i,j) = mean(v_S_Ft(v_Eval));
            stru_Data_S(i,j).Data = v_S_Ft(v_Eval);
            stru_Data_S(i,j).Axis = v_S_Ax(v_Eval);
        catch
            m_mean_S(i,j) = NaN;
            stru_Data_S(i,j).Data = [];
            stru_Data_S(i,j).Axis = [];
        end

    end

    % Trigger

    v_LinSpa = linspace(0,1,s_BinT+1);

    for j=1:numel(v_LinSpa)-1

        s_LimI = v_LinSpa(j);
        s_LimS = v_LinSpa(j+1);

        if j == numel(v_LinSpa)-1
            v_Eval = (s_LimI<=v_T_Ax) & (v_T_Ax<=s_LimS);
        else
            v_Eval = (s_LimI<=v_T_Ax) & (v_T_Ax<s_LimS);
        end

        try
            m_mean_T(i,j) = mean(v_T_Ft(v_Eval));
            stru_Data_T(i,j).Data = v_T_Ft(v_Eval);
            stru_Data_T(i,j).Axis = v_T_Ax(v_Eval);
        catch
            m_mean_T(i,j) = NaN;
            stru_Data_T(i,j).Data = [];
            stru_Data_T(i,j).Axis = [];
        end

    end

end

%% Join plot with bars and pooled points

v_ColorB = [18 18 255]./255;
v_ColorS = [255 98 4]./255;
v_ColorT = [179 26 229]./255;
s_Sz = 13;

v_Plot = [mean(m_mean_B,'omitnan'),mean(m_mean_S,'omitnan'),mean(m_mean_T,'omitnan')];

figure('Position',[1434 336 968 818])
b = bar(v_Plot);
hold on
set(b, 'FaceAlpha', 0.2);
b.FaceColor = 'flat';
b.LineWidth = 0.8;
c = 1;
c2 =1;
for i=1:numel(v_Plot)

    if i<=s_BinB
        b.CData(i,:) = v_ColorB;

        for j=1:size(stru_Data_B,1)
            v_Y = stru_Data_B(j,i).Data;
            v_X = linspace(i-0.4,i+0.4,numel(v_Y));
            plot(v_X,v_Y,'.','MarkerEdgeColor',v_ColorB,'MarkerFaceColor',v_ColorB)      
        end 

    elseif  i>s_BinB && i<=(s_BinB+s_BinS)

        b.CData(i,:) = v_ColorS;

        for j=1:size(stru_Data_S,1)
            v_Y = stru_Data_S(j,c).Data;
            v_X = linspace(i-0.4,i+0.4,numel(v_Y));
            plot(v_X,v_Y,'.','MarkerEdgeColor',v_ColorS,'MarkerFaceColor',v_ColorS)
        end

        c = c+1;
    else
        b.CData(i,:) = v_ColorT;

        for j=1:size(stru_Data_T,1)
            v_Y = stru_Data_T(j,c2).Data;
            v_X = linspace(i-0.4,i+0.4,numel(v_Y));
            plot(v_X,v_Y,'.','MarkerEdgeColor',v_ColorT,'MarkerFaceColor',v_ColorT)
        end

        c2 = c2+1;
    end

end

v_EBar = [std(m_mean_B,'omitmissing'),std(m_mean_S,'omitmissing'),std(m_mean_T,'omitmissing')];

errorbar(v_Plot,v_EBar,'.k','LineWidth',0.8,'Color',[0.4,0.4,0.4])
ylabel('mean norm amplitude','FontSize',s_Sz)
xlabel('pooled data in bins peer subperiods','FontSize',s_Sz)
title('amplitude','FontSize',s_Sz)
set(gca,'FontSize',s_Sz)

%% Delete NaN rows (only for stats)

v_Del = isnan(mean(m_mean_B,2));
m_mean_B(v_Del,:)=[];
stru_Data_B(v_Del,:)=[];

v_Del = isnan(mean(m_mean_S,2));
m_mean_S(v_Del,:)=[];
stru_Data_S(v_Del,:)=[];

v_Del = isnan(mean(m_mean_T,2));
m_mean_T(v_Del,:)=[];
stru_Data_T(v_Del,:)=[];

%% Stats

%%
[p_b,~,stats] = friedman(m_mean_B);
figure()
c_b = multcompare(stats,'CriticalValueType','dunn-sidak');
title('Build-up groups')

f_ImageMultiComp(c_b,0.05)
%title('Multicomparison test dunn-sidak','FontSize',s_Sz')
set(gca,'FontSize',s_Sz)

%%
[p_s,~,stats] = friedman(m_mean_S);
figure()
c_s = multcompare(stats,'CriticalValueType','dunn-sidak');
title('Steady-State groups')


f_ImageMultiComp(c_s,0.05)
set(gca,'FontSize',s_Sz)

%%
[p_t,~,stats] = friedman(m_mean_T);
figure()
c_t = multcompare(stats,'CriticalValueType','dunn-sidak');
title('Trigger groups')

f_ImageMultiComp(c_t,0.05)
set(gca,'FontSize',s_Sz)

%% Quantifications absolute values
close all

m_Quan_B(1,:) = mean(m_mean_B);
m_Quan_B(2,:) = std(m_mean_B);
m_Quan_B(3,:) = min(m_mean_B);
m_Quan_B(4,:) = max(m_mean_B);
[r,~]=size(m_mean_B)

m_Quan_S(1,:) = mean(m_mean_S);
m_Quan_S(2,:) = std(m_mean_S);
m_Quan_S(3,:) = min(m_mean_S);
m_Quan_S(4,:) = max(m_mean_S);
[r,~]=size(m_mean_S)

m_Quan_T(1,:) = mean(m_mean_T);
m_Quan_T(2,:) = std(m_mean_T);
m_Quan_T(3,:) = min(m_mean_T);
m_Quan_T(4,:) = max(m_mean_T);
[r,~]=size(m_mean_T)