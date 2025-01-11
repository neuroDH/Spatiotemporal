%% Cleaning
clear; close all; clc;

%% Loading

load('HFO_BST.mat')

%% Points pooled and bars (matrix for stats and charts)

s_BinB = 12;
s_BinS = 5;
s_BinT = 1;

m_BinEven_B = zeros(numel(stru_MergData),s_BinB);
m_BinEven_S = zeros(numel(stru_MergData),s_BinS);
m_BinEven_T = zeros(numel(stru_MergData),s_BinT);

v_B_Bin_Dur_Sec = zeros(numel(stru_MergData),1);
v_S_Bin_Dur_Sec = zeros(numel(stru_MergData),1);
v_T_Bin_Dur_Sec = zeros(numel(stru_MergData),1);

%% PID

for i=1:numel(stru_MergData)

    v_Axis = stru_MergData(i).HFO_B;
    
    s_B = stru_MergData(i).BU;
    s_S = stru_MergData(i).SS;
    s_T = stru_MergData(i).TG;
    s_SO = stru_MergData(i).SO;

    % Features asociated to BU period %

    % Build up

    v_Sel = v_Axis>=s_B & v_Axis<s_S;

    if sum(v_Sel)~=0

        v_B_Ax = v_Axis(v_Sel);
        s_B_Bin_Dur = (v_B_Ax(end)-v_B_Ax(1))/s_BinB;
        v_B_Bin_Dur_Sec(i,1) = s_B_Bin_Dur/10000;
        v_B_Ax = (v_B_Ax-min(v_B_Ax))/(max(v_B_Ax)-min(v_B_Ax));

        % Bining

        v_LinSpa = linspace(0,1,s_BinB+1);

        for j=1:numel(v_LinSpa)-1

            s_LimI = v_LinSpa(j);
            s_LimS = v_LinSpa(j+1);

            if j == numel(v_LinSpa)-1
                v_Eval = (s_LimI<=v_B_Ax) & (v_B_Ax<=s_LimS);
            else
                v_Eval = (s_LimI<=v_B_Ax) & (v_B_Ax<s_LimS);
            end

            m_BinEven_B(i,j) = numel(v_B_Ax(v_Eval));

        end

    end
    % Steady state

    v_Sel = v_Axis>=s_S & v_Axis<s_T;
    
    if sum(v_Sel)~=0
        v_S_Ax = v_Axis(v_Sel);
        s_S_Bin_Dur = (v_S_Ax(end)-v_S_Ax(1))/s_BinS;
        v_S_Bin_Dur_Sec(i,1) = s_S_Bin_Dur/10000;
        v_S_Ax = (v_S_Ax-min(v_S_Ax))/(max(v_S_Ax)-min(v_S_Ax));

        % Bining

        v_LinSpa = linspace(0,1,s_BinS+1);

        for j=1:numel(v_LinSpa)-1

            s_LimI = v_LinSpa(j);
            s_LimS = v_LinSpa(j+1);

            if j == numel(v_LinSpa)-1
                v_Eval = (s_LimI<=v_S_Ax) & (v_S_Ax<=s_LimS);
            else
                v_Eval = (s_LimI<=v_S_Ax) & (v_S_Ax<s_LimS);
            end

            m_BinEven_S(i,j) = numel(v_S_Ax(v_Eval));

        end
    end

    %Trigger

    v_Sel = v_Axis>=s_T;
    
    if sum(v_Sel)~=0

        v_T_Ax = v_Axis(v_Sel);

        s_T_Bin_Dur = (v_T_Ax(end)-v_T_Ax(1))/s_BinT;
        v_T_Bin_Dur_Sec(i,1) = s_T_Bin_Dur/10000;

        v_T_Ax = (v_T_Ax-min(v_T_Ax))/(max(v_T_Ax)-min(v_T_Ax));


        v_LinSpa = linspace(0,1,s_BinT+1);

        for j=1:numel(v_LinSpa)-1

            s_LimI = v_LinSpa(j);
            s_LimS = v_LinSpa(j+1);

            if j == numel(v_LinSpa)-1
                v_Eval = (s_LimI<=v_T_Ax) & (v_T_Ax<=s_LimS);
            else
                v_Eval = (s_LimI<=v_T_Ax) & (v_T_Ax<s_LimS);
            end

            m_BinEven_T(i,j) = numel(v_T_Ax(v_Eval));

        end
    end

    % v_Plot = [m_mean_I(i,:),m_mean_B(i,:),m_mean_S(i,:),m_mean_T(i,:)];
    % subplot(1,2,2)
    % bar(v_Plot)

end

v_B_Rem = v_B_Bin_Dur_Sec==0;
v_B_Bin_Dur_Sec(v_B_Rem)=[];
m_BinEven_B(v_B_Rem,:)=[];

v_S_Rem = v_S_Bin_Dur_Sec==0;
v_S_Bin_Dur_Sec(v_S_Rem)=[];
m_BinEven_S(v_S_Rem,:)=[];

v_T_Rem = v_T_Bin_Dur_Sec==0;
v_T_Bin_Dur_Sec(v_T_Rem)=[];
m_BinEven_T(v_T_Rem,:)=[];

m_MeanDur_B = m_BinEven_B./v_B_Bin_Dur_Sec;
m_MeanDur_S = m_BinEven_S./v_S_Bin_Dur_Sec;
m_MeanDur_T = m_BinEven_T./v_T_Bin_Dur_Sec;

% m_MeanDur_IID(m_MeanDur_IID==0)=NaN;
% m_MeanDur_B(m_MeanDur_B==0)=NaN;
% m_MeanDur_S(m_MeanDur_S==0)=NaN;
% m_MeanDur_T(m_MeanDur_T==0)=NaN;


%% Join plot with bars and pooled points

v_ColorB = [18 18 255]./255;
v_ColorS = [255 98 4]./255;
v_ColorT = [179 26 229]./255;
s_Sz = 13;

v_Plot = [mean(m_MeanDur_B,'omitnan'),...
    mean(m_MeanDur_S,'omitnan'),mean(m_MeanDur_T,'omitnan')];

figure('Position',[1434 336 968 818])
b = bar(v_Plot);
hold on
set(b, 'FaceAlpha', 0.2);
b.FaceColor = 'flat';
b.LineWidth = 0.8;

c1 = 1;
c2 =1;

for i=1:numel(v_Plot)

    if i<=s_BinB

        b.CData(i,:) = v_ColorB;      

    elseif i>s_BinB && i<=(s_BinB+s_BinS)

        b.CData(i,:) = v_ColorS;     
        c1 = c1+1;

    else

        b.CData(i,:) = v_ColorT;
        c2 = c2+1;
    end
 
end

v_EBar = [std(m_MeanDur_B,'omitmissing'),...
    std(m_MeanDur_S,'omitmissing'),std(m_MeanDur_T,'omitmissing')];

errorbar(v_Plot,v_EBar,'.k','LineWidth',1.2,'Color',[0.4,0.4,0.4])
ylabel('mean number of events peer second','FontSize',s_Sz)
xlabel('pooled data in bins peer subperiods','FontSize',s_Sz)
title('Number of events','FontSize',s_Sz)
set(gca,'FontSize',s_Sz)


[p_b,~,stats] = friedman(m_MeanDur_B);
[p_b,~,stats] = friedman(m_MeanDur_S);