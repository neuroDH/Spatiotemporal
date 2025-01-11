% Speed gilles

%% Cleaning
clear; close all; clc

str_DataPath = 'C:\Users\david\Desktop\All_Data\Data\';
load('Names.mat')

v_Slices = [9,14,15,16,17,18,25];

for ii = 1: numel(v_Slices)

    clearvars -except ii v_Slices str_DataPath stru_FolderNames stru_Speed m_mean_B m_mean_S m_mean_T stru_Data_B stru_Data_S stru_Data_T m_Dur

    %% Concurrent events detection

    str_SliceName = strcat(stru_FolderNames(v_Slices(ii)).Slice,'\');
    load(strcat(str_DataPath,str_SliceName,'Peaks.mat'),'stru_Pks')        % Load all PID pks.

    load('PksConcu.mat','stru_PksAve')                                     % Load avg pks.
    v_Indx = stru_PksAve(v_Slices(ii)).PksAve;

    % Create a single matrix with all the PID peaks that are inside the
    % centered window (concurrent peaks reference)

    s_Win = 1600;                                                              % 160 ms

    for i = 1:numel(v_Indx)

        s_LimInf = v_Indx(i)-(s_Win/2);
        s_LimSup = v_Indx(i)+(s_Win/2);

        v_Pk_Indx = [];

        for j=1:numel(stru_Pks)

            v_PksTemp = stru_Pks(j).PksIndx;
            v_Bol = logical((v_PksTemp>=s_LimInf) & (v_PksTemp<=s_LimSup));
            s_PkIdx = v_PksTemp(v_Bol);
            %s_PkIdx = unique(s_PkIdx);

            if isempty(s_PkIdx)
                v_Pk_Indx(j,1) = nan;
            else
                v_Pk_Indx(j,1) = s_PkIdx;
            end

        end

        m_Indx_Pks_win(:,i) = v_Pk_Indx;

    end

    % Verify repeated elements in the same row

    v_Dup = [];
    for i=1:size(m_Indx_Pks_win,1)
        A =  m_Indx_Pks_win(i,:);
        [~, uniqueIdx] = unique(A);
        duplicateLocations = ismember(A, find(A(setdiff( 1:numel(A),uniqueIdx))));
        v_Dup(i) = sum(duplicateLocations);
    end

    if sum(v_Dup)==0
        disp('Pks matrix is good! There are not repeated elements ')
    else
        disp('Check Pks matrix duplicates')
    end

    % Take each frame, remove those with more than 114 NaN and sort Pks

    m_New_Indx = m_Indx_Pks_win;
    cont = 0;

    for d=1:size(m_New_Indx,2)

        v_Frame = m_New_Indx(:,d);
        s_numNaN = sum(isnan(v_Frame));

        if s_numNaN>= 115
            continue
        else

            [v_Indx,v_Elec] = sort(v_Frame);
            s_NaN = find(isnan(v_Indx),1);
            v_Indx(s_NaN:end)=[];
            v_Elec(s_NaN:end)=[];
            cont = cont+1;

            stru_Sort_PID(cont).Indx = v_Indx;
            stru_Sort_PID(cont).Elec = v_Elec;

        end

    end

    %% Compute speed (Gilles proposal, between first and last PID concurrent PID)

    % Get spatial distribution between electrodes

    s_XDis = 0.2;                                                              % mm -> 200 um
    s_YDis = 0.2;                                                              % mm -> 200 um
    s_NElecX = 12;
    s_NElecY = 12;
    v_X = 0:s_XDis:(s_XDis*s_NElecX)-s_XDis;
    v_Y = 0:s_YDis:(s_YDis*s_NElecY)-s_YDis;
    [m_X,m_Y] = meshgrid(v_X,v_Y);

    % Load electrodes distribution

    load('Sll_Mat_Dis.mat','m_IndxOri')

    v_ReX = [1,1,1,1,1,1,2,2,2,2,3,3,10,11,11,12,12,12,10,11,11,12,12,12];
    v_ReY = [1,2,3,10,11,12,1,2,11,12,1,12,1,1,2,1,2,3,12,11,12,10,11,12];

    % Remove corners

    for i = 1:numel(v_ReY)
        m_X(v_ReX(i),v_ReY(i)) = nan;
        m_Y(v_ReX(i),v_ReY(i)) = nan;
        m_IndxOri(v_ReX(i),v_ReY(i)) = nan;
    end

    % Get firing time, its correspondient x,y coordenates, compute distance
    % and speed

    v_Speed=[];
    v_Ref = [];

    for i = 1:numel(stru_Sort_PID)

        v_Elec = stru_Sort_PID(i).Elec;
        v_Time = stru_Sort_PID(i).Indx;

        s_F_Elec = v_Elec(1);
        s_L_Elec = v_Elec(end);

        s_F_Time = v_Time(1);
        s_L_Time = v_Time(end);
        s_TimeDiff_s = (s_L_Time-s_F_Time)./10000;

        [a,b] = find(m_IndxOri==s_F_Elec);
        [c,d] = find(m_IndxOri==s_L_Elec);

        s_X2 = (m_X(a,b)-m_X(c,d))^2;
        s_Y2 = (m_Y(a,b)-m_Y(c,d))^2;

        s_Dist_mm = sqrt(s_X2+s_Y2);
        s_Dist_m = sqrt(s_X2+s_Y2)/1000;

        v_Speed(i) = s_Dist_m/s_TimeDiff_s;
        v_Ref(i) = s_F_Time;

    end

    stru_Speed(ii).Speed = v_Speed;
    stru_Speed(ii).TimeRef = v_Ref;

    % max(v_Speed)
    % min(v_Speed)
    % mean(v_Speed)

    %% Bining (BU, SS, TG)

    % Number of bins

    s_BinB = 14;
    s_BinS = 8;
    s_BinT = 1;

    % Features

    v_Feat = v_Speed;
    %v_Feat = (v_Feat-min(v_Feat))./(max(v_Feat)-min(v_Feat));
    
    v_Axis = v_Ref;

    % Time stamps peer subperiod

    s_S = stru_FolderNames(v_Slices(ii)).SS;
    s_T = stru_FolderNames(v_Slices(ii)).TG;

    % Build up

    v_Sel = v_Axis<s_S;

    v_B_Ax = v_Axis(v_Sel);
    s_Dur_B = v_B_Ax(end)-v_B_Ax(1);
    v_B_Ft = v_Feat(v_Sel);

    v_B_Ax = (v_B_Ax-min(v_B_Ax))/(max(v_B_Ax)-min(v_B_Ax));               % Normalization

    % Steady state

    v_Sel = v_Axis>=s_S & v_Axis<s_T;

    v_S_Ax = v_Axis(v_Sel);
    s_Dur_S = v_S_Ax(end)-v_S_Ax(1);
    v_S_Ft = v_Feat(v_Sel);

    v_S_Ax = (v_S_Ax-min(v_S_Ax))/(max(v_S_Ax)-min(v_S_Ax));               % Normalization

    %Trigger

    v_Sel = v_Axis>=s_T;

    v_T_Ax = v_Axis(v_Sel);
    s_Dur_T = v_T_Ax(end)-v_T_Ax(1);
    v_T_Ft = v_Feat(v_Sel);

    v_T_Ax = (v_T_Ax-min(v_T_Ax))/(max(v_T_Ax)-min(v_T_Ax));               % Normalization

    m_Dur(ii,:) = [s_Dur_B,s_Dur_S,s_Dur_T];

    % Bining

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

        m_mean_B(ii,j) = mean(v_B_Ft(v_Eval));
        stru_Data_B(ii,j).Data = v_B_Ft(v_Eval);
        stru_Data_B(ii,j).Axis = v_B_Ax(v_Eval);

    end

    % Steady

    v_LinSpa = linspace(0,1,s_BinS+1);

    for j=1:numel(v_LinSpa)-1

        s_LimI = v_LinSpa(j);
        s_LimS = v_LinSpa(j+1);

        if j == numel(v_LinSpa)-1
            v_Eval = (s_LimI<=v_S_Ax) & (v_S_Ax<=s_LimS);
        else
            v_Eval = (s_LimI<=v_S_Ax) & (v_S_Ax<s_LimS);
        end

        m_mean_S(ii,j) = mean(v_S_Ft(v_Eval));
        stru_Data_S(ii,j).Data = v_S_Ft(v_Eval);
        stru_Data_S(ii,j).Axis = v_S_Ax(v_Eval);

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

        m_mean_T(ii,j) = mean(v_T_Ft(v_Eval));
        stru_Data_T(ii,j).Data = v_T_Ft(v_Eval);
        stru_Data_T(ii,j).Axis = v_T_Ax(v_Eval);
    end
end

%% Bar plot

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
ylabel('mean speed (m/s)','FontSize',s_Sz)
xlabel('pooled data in bins peer subperiods','FontSize',s_Sz)
title('Speed','FontSize',s_Sz)

%% Speed line plot and binnig without subperiods

s_Bin = 23;
figure()

for h=1:numel(stru_Speed)

    v_Y = stru_Speed(h).Speed;
    v_X = stru_Speed(h).TimeRef;
    v_X_Nor = (v_X-min(v_X))/(max(v_X)-min(v_X));                          % Normalization
    %plot(v_X_Nor,v_Y,'.')
    plot(v_X_Nor,v_Y)
    hold on

    v_LinSpa = linspace(0,1,s_Bin+1);

    for j=1:numel(v_LinSpa)-1

        s_LimI = v_LinSpa(j);
        s_LimS = v_LinSpa(j+1);

        if j == numel(v_LinSpa)-1
            v_Eval = (s_LimI<=v_X_Nor) & (v_X_Nor<=s_LimS);
        else
            v_Eval = (s_LimI<=v_X_Nor) & (v_X_Nor<s_LimS);
        end

        m_mean_Bin (h,j) = mean(v_Y(v_Eval));
        stru_Data_Bin(h,j).Data = v_Y(v_Eval);
        stru_Data_Bin(h,j).Axis = v_X_Nor(v_Eval);

    end

end

ylabel('speed (m/s)','FontSize',s_Sz)
xlabel('normalized time','FontSize',s_Sz)
title('Speed poins all slices (Small matrix)','FontSize',s_Sz)
ylim([0,0.12])

s_Sz = 13;

v_Plot = mean(m_mean_Bin,'omitnan');

figure('Position',[1434 336 968 818])
b = bar(v_Plot);
hold on
set(b, 'FaceAlpha', 0.2);
b.FaceColor = 'flat';
b.LineWidth = 0.2;

for i=1:numel(v_Plot)

     b.CData(i,:) = [0 0 0];

    for j=1:size(stru_Data_Bin,1)
        v_Y = stru_Data_Bin(j,i).Data;
        v_X = linspace(i-0.4,i+0.4,numel(v_Y));
        plot(v_X,v_Y,'.','MarkerEdgeColor','k','MarkerFaceColor','k')
    end

end

v_EBar = [std(m_mean_Bin,'omitmissing')];

errorbar(v_Plot,v_EBar,'.k','LineWidth',0.8,'Color',[0.4,0.4,0.4])
ylabel('mean speed peer bin (m/s)','FontSize',s_Sz)
xlabel('pooled data in bins','FontSize',s_Sz)
title('Speed','FontSize',s_Sz)
ylim([0,0.045])

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
[p_t,~,stats] = friedman(m_mean_Bin);
figure()
c_t = multcompare(stats,'CriticalValueType','dunn-sidak');
title('No subperiods groups')

f_ImageMultiComp(c_t,0.05)
set(gca,'FontSize',s_Sz)