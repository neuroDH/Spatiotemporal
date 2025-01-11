%% Cleaning

clear; close all; clc

%% Bins # events in time one single slice

load('Names.mat')
m_Plot = [];

for ii = 1:numel(stru_FolderNames)

    clearvars -except ii stru_FolderNames m_Plot

    str_DataPath = 'C:\Users\david\Desktop\Desktop_David\All_Data\Data\';
    str_SliceName = strcat(stru_FolderNames(ii).Slice,'\');
    load(strcat(str_DataPath,str_SliceName,'Candidates_HFO.mat'))
    load(strcat(str_DataPath,str_SliceName,'Peaks.mat'))

    % Build intervals each subperiod

    s_SampSS = stru_FolderNames(ii).SS;
    s_SampTG = stru_FolderNames(ii).TG;
    s_SampSO = stru_FolderNames(ii).SO;

    s_ElecRef = stru_FolderNames(ii).Elec;
    v_PksRef = stru_Pks(s_ElecRef).PksIndx;

    s_InfBU = v_PksRef(1);
    s_SupBU = v_PksRef(numel(find(v_PksRef<=s_SampSS)));

    s_InfSS = v_PksRef(numel(find(v_PksRef<=s_SampSS))+1);
    s_SupSS = v_PksRef(numel(find(v_PksRef<=s_SampTG)));

    s_InfTG = v_PksRef(numel(find(v_PksRef<=s_SampTG))+1);
    s_SupTG = v_PksRef(numel(find(v_PksRef<=s_SampSO)));

    % Num active electrodes

    v_ActEl = [];

    for z=1:numel(struHFO)

        v_IsHFO = (struHFO(z).VisualInspec_Final)==1;

        if ismember(1,v_IsHFO)
            v_ActEl(z,1) = 1;
        else
            v_ActEl(z,1) = 0;
        end
    end

    s_AcEle = sum(v_ActEl);

    %% Bins

    m_NumEvents = [];
    s_BinsBU = 12;
    s_BinsSS = 5;
    s_BinsTG = 1;

    for dd=1:numel(struHFO)

        v_HFOTrue = (struHFO(dd).VisualInspec_Final)==1;
        
        if isempty(v_HFOTrue)

            m_HFORef = [];
            v_HFORef = [];
            m_NumEvents(dd,:) = [zeros(1,s_BinsBU),zeros(1,s_BinsSS),zeros(1,s_BinsTG)];

            continue
        else
            m_HFORef = struHFO(dd).m_HFOCandidates;
            v_HFORef = m_HFORef(v_HFOTrue,1);            
        end

        % Build up

        v_NumPks_B = [];
        v_InterBU = floor(linspace(s_InfBU,s_SupBU,s_BinsBU+1));

        for j=1:numel(v_InterBU)-1

            s_LimI = v_InterBU(j);
            s_LimS = v_InterBU(j+1);

            if j == numel(v_InterBU)-1
                v_Eval = (s_LimI<=v_HFORef) & (v_HFORef<=s_LimS);
            else
                v_Eval = (s_LimI<=v_HFORef) & (v_HFORef<s_LimS);
            end

            v_NumPks_B(j) = sum(v_Eval);

        end

        % Steady state

        v_NumPks_S = [];
        v_InterSS = floor(linspace(s_InfSS,s_SupSS,s_BinsSS+1));

        for j=1:numel(v_InterSS)-1

            s_LimI = v_InterSS(j);
            s_LimS = v_InterSS(j+1);

            if j == numel(v_InterSS)-1
                v_Eval = (s_LimI<=v_HFORef) & (v_HFORef<=s_LimS);
            else
                v_Eval = (s_LimI<=v_HFORef) & (v_HFORef<s_LimS);
            end

            v_NumPks_S(j) = sum(v_Eval);

        end

        % Trigger

        v_NumPks_T = [];
        v_InterTG = floor(linspace(s_InfTG,s_SupTG,s_BinsTG+1));

        for j=1:numel(v_InterTG)-1

            s_LimI = v_InterTG(j);
            s_LimS = v_InterTG(j+1);

            if j == numel(v_InterTG)-1
                v_Eval = (s_LimI<=v_HFORef) & (v_HFORef<=s_LimS);
            else
                v_Eval = (s_LimI<=v_HFORef) & (v_HFORef<s_LimS);
            end

            v_NumPks_T(j) = sum(v_Eval);

        end

        m_NumEvents(dd,:) = [v_NumPks_B,v_NumPks_S,v_NumPks_T];

    end

    m_Plot(ii,:) = (100*sum(m_NumEvents~=0))./s_AcEle;

end
%% Remove Nan

v_isNan = isnan(m_Plot(:,1));
m_Plot(v_isNan,:)=[];

%% Plot
v_ColorB = [18 18 255]./255;
v_ColorS = [255 98 4]./255;
v_ColorT = [179 26 229]./255;
s_Sz = 13;

v_Plot = mean(m_Plot);

figure('Position',[1434 336 968 818])
b = bar(v_Plot);
hold on
set(b, 'FaceAlpha', 0.2);
b.FaceColor = 'flat';
b.LineWidth = 0.8;
c = s_BinsBU+1;
c2 =c+s_BinsSS;
for i=1:numel(v_Plot)

    if i<=s_BinsBU

        b.CData(i,:) = v_ColorB;

        v_Y = m_Plot(:,i);
        v_X = linspace(i-0.4,i+0.4,numel(v_Y));
        plot(v_X,v_Y,'.','MarkerEdgeColor',v_ColorB,'MarkerFaceColor',v_ColorB)


    elseif  i>s_BinsBU && i<=(s_BinsBU+s_BinsSS)

        b.CData(i,:) = v_ColorS;


        v_Y = m_Plot(:,c);
        v_X = linspace(i-0.4,i+0.4,numel(v_Y));
        plot(v_X,v_Y,'.','MarkerEdgeColor',v_ColorS,'MarkerFaceColor',v_ColorS)


        c = c+1;
    else
        b.CData(i,:) = v_ColorT;

        v_Y = m_Plot(:,c2);
        v_X = linspace(i-0.4,i+0.4,numel(v_Y));
        plot(v_X,v_Y,'.','MarkerEdgeColor',v_ColorT,'MarkerFaceColor',v_ColorT)


        c2 = c2+1;
    end

end

v_EBar = std(m_Plot,'omitmissing');

errorbar(v_Plot,v_EBar,'.k','LineWidth',0.8,'Color',[0.4,0.4,0.4])
ylabel('mean of % active electrodes','FontSize',s_Sz)
xlabel('bining data peer subperiods','FontSize',s_Sz)
title('Active electrodes in time','FontSize',s_Sz)
set(gca,'FontSize',s_Sz)

% %% Delete NaN files (for stats)
% 
% v_Del = isnan(mean(m_mean_B,2));
% m_mean_B(v_Del,:)=[];
% stru_Data_B(v_Del,:)=[];
% 
% v_Del = isnan(mean(m_mean_S,2));
% m_mean_S(v_Del,:)=[];
% stru_Data_S(v_Del,:)=[];
% 
% v_Del = isnan(mean(m_mean_T,2));
% m_mean_T(v_Del,:)=[];
% stru_Data_T(v_Del,:)=[];

%% Stats

%%
[p_b,~,stats] = friedman(m_Plot(:,1:s_BinsBU));
figure()
c_b = multcompare(stats,'CriticalValueType','dunn-sidak');
title('Build-up groups')

f_ImageMultiComp(c_b,0.05)
%title('Multicomparison test dunn-sidak','FontSize',s_Sz')
set(gca,'FontSize',s_Sz)

%%
[p_s,~,stats] = friedman(m_Plot(:,s_BinsBU+1:s_BinsBU+s_BinsSS));
figure()
c_s = multcompare(stats,'CriticalValueType','dunn-sidak');
title('Steady-State groups')


f_ImageMultiComp(c_s,0.05)
set(gca,'FontSize',s_Sz)

%%
[p_t,~,stats] = friedman(m_Plot(:,s_BinsBU+s_BinsSS+1:end));
figure()
c_t = multcompare(stats,'CriticalValueType','dunn-sidak');
title('Trigger groups')

f_ImageMultiComp(c_t,0.05)
set(gca,'FontSize',s_Sz)