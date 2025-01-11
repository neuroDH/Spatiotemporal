%% Cleaning

clear; close all; clc

%% Bins # events in time one single slice

load('Names.mat')
for ii = 1:numel(stru_FolderNames)

    clearvars -except ii stru_FolderNames

    str_DataPath = 'C:\Users\david\Desktop\All_Data\Data\';
    str_SliceName = strcat(stru_FolderNames(ii).Slice,'\');
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

    % Number of bins

    s_BinsTG = 2;

    v_Cal = [s_SupBU-s_InfBU,s_SupSS-s_InfSS,(s_SupTG-s_InfTG)/s_BinsTG];

    s_BinsBU = floor(v_Cal(1)/v_Cal(3));
    s_BinsSS = floor(v_Cal(2)/v_Cal(3));


    %% Bins

    m_NumEvents = [];
    
    for dd=1:numel(stru_Pks)

        v_PksRef = stru_Pks(dd).PksIndx;

        % Build up

        v_NumPks_B = [];
        % s_BinsBU = 10;
        v_InterBU = floor(linspace(s_InfBU,s_SupBU,s_BinsBU+1));

        for j=1:numel(v_InterBU)-1

            s_LimI = v_InterBU(j);
            s_LimS = v_InterBU(j+1);

            if j == numel(v_InterBU)-1
                v_Eval = (s_LimI<=v_PksRef) & (v_PksRef<=s_LimS);
            else
                v_Eval = (s_LimI<=v_PksRef) & (v_PksRef<s_LimS);
            end

            v_NumPks_B(j) = sum(v_Eval);

        end

        % Steady state

        v_NumPks_S = [];
        % s_BinsSS = 16;
        v_InterSS = floor(linspace(s_InfSS,s_SupSS,s_BinsSS+1));

        for j=1:numel(v_InterSS)-1

            s_LimI = v_InterSS(j);
            s_LimS = v_InterSS(j+1);

            if j == numel(v_InterSS)-1
                v_Eval = (s_LimI<=v_PksRef) & (v_PksRef<=s_LimS);
            else
                v_Eval = (s_LimI<=v_PksRef) & (v_PksRef<s_LimS);
            end

            v_NumPks_S(j) = sum(v_Eval);

        end

        % Trigger

        v_NumPks_T = [];
        % s_BinsTG = 2;
        v_InterTG = floor(linspace(s_InfTG,s_SupTG,s_BinsTG+1));

        for j=1:numel(v_InterTG)-1

            s_LimI = v_InterTG(j);
            s_LimS = v_InterTG(j+1);

            if j == numel(v_InterTG)-1
                v_Eval = (s_LimI<=v_PksRef) & (v_PksRef<=s_LimS);
            else
                v_Eval = (s_LimI<=v_PksRef) & (v_PksRef<s_LimS);
            end

            v_NumPks_T(j) = sum(v_Eval);

        end

        m_NumEvents(dd,:) = [v_NumPks_B,v_NumPks_S,v_NumPks_T];

        % figure()
        % bar([v_NumPks_B,v_NumPks_S,v_NumPks_T])

    end

    %% Join plot with bars and pooled points

    v_ColorB = [18 18 255]./255;
    v_ColorS = [255 98 4]./255;
    v_ColorT = [179 26 229]./255;
    s_Sz = 13;

    v_Plot = sum(m_NumEvents);
    v_Plot2 = sum(m_NumEvents~=0);

    f = figure('Position',[ 453 317 1764 826]);
    subplot(1,2,1)
    b = bar(v_Plot);
    hold on
    set(b, 'FaceAlpha', 0.2);
    b.FaceColor = 'flat';
    b.LineWidth = 0.8;

    ylabel('number of PIDs all electrodes','FontSize',s_Sz)
    xlabel('pooled data in bins peer subperiods','FontSize',s_Sz)
    title('Number of PIDs in time','FontSize',s_Sz)
    set(gca,'FontSize',s_Sz)

    subplot(1,2,2)
    d = bar(v_Plot2);
    hold on
    set(d, 'FaceAlpha', 0.2);
    d.FaceColor = 'flat';
    d.LineWidth = 0.8;
    ylim([0,max(v_Plot2)+20])
    %v_EBar = std(m_NumEvents);
    %errorbar(v_Plot,v_EBar,'.k','LineWidth',0.8,'Color',[0.4,0.4,0.4])
    ylabel('number of active electrodes','FontSize',s_Sz)
    xlabel('pooled data in bins peer subperiods','FontSize',s_Sz)
    title('Number of active electrodes in time','FontSize',s_Sz)
    set(gca,'FontSize',s_Sz)

    c = 1;
    c2 =1;
    for i=1:numel(v_Plot)

        if i<=s_BinsBU
            b.CData(i,:) = v_ColorB;
            d.CData(i,:) = v_ColorB;

        elseif  i>s_BinsBU && i<=(s_BinsBU+s_BinsSS)

            b.CData(i,:) = v_ColorS;
            d.CData(i,:) = v_ColorS;
            c = c+1;

        else
            b.CData(i,:) = v_ColorT;
            d.CData(i,:) = v_ColorT;
            c2 = c2+1;
        end

    end

    %floor([2834554,4515611,559786]./[10,16,2])
    saveas(f,strcat(stru_FolderNames(ii).Slice,'.png'))
    close (f)

end
