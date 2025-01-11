%% Cleaning
clear; close all; clc

%% Path and load
ii=16;
load('Names.mat')
str_DataPath = 'C:\Users\david\Desktop\All_Data\Data\';
str_Slice = stru_FolderNames(ii).Slice;
str_path2Load = strcat(str_DataPath,str_Slice);

load('Features2Plot.mat','stru_Sort_PID')

%% Plot

s_NumFra = size(stru_Sort_PID,2); 

%% PID amplitude

for i=1:s_NumFra
    v_Feat = stru_Sort_PID(i).PIDAmp;
    v_Max(i) = max(v_Feat);
    v_Min(i) = min(v_Feat);
end
s_minData = min(v_Min);
s_maxData = max(v_Max);

str_Feat = 'AMP';
mkdir(str_Feat)

for i=1:s_NumFra

    v_Elec = stru_Sort_PID(i).Elec;
    v_Feat = stru_Sort_PID(i).PIDAmp;
    [m_Data] = f_Get_Matrix2Plot(v_Elec,v_Feat,str_path2Load);

    m_Data(m_Data == 0)= nan;
    % s_minData = min(min(m_Data));
    % s_maxData = max(max(m_Data));
    m_Data = (m_Data-s_minData)/(s_maxData-s_minData);

    s = pcolor(m_Data);
    s.FaceColor = 'interp';
    set(gca, 'YDir','reverse')
    set(gca, 'CLim',[0.2,0.8])
    colormap ('jet')
    colorbar
    title('PID amplitude','FontSize',14)

%     cmp = colormap;
%     cmp = flipud(cmp);
%     colormap(cmp)

    f1 = gcf;
    ax1 = gca;
    set(f1,'Position',[482 225.5 740 597])
    set(ax1,'Position',[0.04,0.05,0.8,0.9])
    set(f1,'Color','w')
    axis off

    str_Name2Save = strcat('./',str_Feat,'/',num2str(i),'_',str_Feat,'.png');

    F = getframe(f1);
    [X, Map] = frame2im(F);
    imwrite(X,str_Name2Save)
    close (f1)
    
end

%% PID firetime

str_Feat = 'TIM';
mkdir(str_Feat)

for i=1:s_NumFra

    v_Elec = stru_Sort_PID(i).Elec;
    v_Feat = stru_Sort_PID(i).Indx;
    [m_Data] = f_Get_Matrix2Plot(v_Elec,v_Feat,str_path2Load);

    m_Data(m_Data == 0)= nan;
    s_minData = min(min(m_Data));
    s_maxData = max(max(m_Data));
    m_Data = (m_Data-s_minData)/(s_maxData-s_minData);

    s = pcolor(m_Data);
    s.FaceColor = 'interp';
    set(gca, 'YDir','reverse')
    colormap ('jet')
    colorbar
    title('PID firetime','FontSize',14)

    cmp = colormap;
    cmp = flipud(cmp);
    colormap(cmp)

    f1 = gcf;
    ax1 = gca;
    set(f1,'Position',[482 225.5 740 597])
    set(ax1,'Position',[0.04,0.05,0.8,0.9])
    set(f1,'Color','w')
    axis off

    str_Name2Save = strcat('./',str_Feat,'/',num2str(i),'_',str_Feat,'.png');

    F = getframe(f1);
    [X, Map] = frame2im(F);
    imwrite(X,str_Name2Save)
    close (f1)
    
end

%% Colormap binary

m_Colormap = [
    1.0, 1.0, 1.0;  % Blanco para el valor más bajo
    0.0, 0.0, 0.5;  % Azul para el valor medio
    0.5, 0.0, 0.0   % Rojo para el valor más alto
];

%% HFA ocurrence

str_Feat = 'HFA';
mkdir(str_Feat)

for i=1:s_NumFra

    v_Elec = stru_Sort_PID(i).Elec;
    v_Feat = stru_Sort_PID(i).HFAOcu;
    [m_Data] = f_Get_Matrix2Plot(v_Elec,v_Feat,str_path2Load);

    %s = pcolor(m_Data);
    s = imagesc(m_Data);
    % s.FaceColor = 'interp';
    %set(gca, 'YDir','reverse')
    set(gca, 'CLim',[-1,1])
    colormap (m_Colormap)
    title('HFA electrodes','FontSize',14)
    %colorbar
    xticks(0.5:12.5)
    yticks(0.5:12.5)
    grid on

    f1 = gcf;
    ax1 = gca;
    set(f1,'Position',[482 225.5 740 597])
    %set(ax1,'Position',[0.04,0.05,0.8,0.9])
    set(f1,'Color','w')
    ax1.XTickLabel = [];
    ax1.YTickLabel = [];

    str_Name2Save = strcat('./',str_Feat,'/',num2str(i),'_',str_Feat,'.png');

    F = getframe(f1);
    [X, Map] = frame2im(F);
    imwrite(X,str_Name2Save)
    close (f1)
    
end

%% HFO ocurrence

str_Feat = 'HFO';
mkdir(str_Feat)

for i=1:s_NumFra

    v_Elec = stru_Sort_PID(i).Elec;
    v_Feat = stru_Sort_PID(i).HFOOcu;
    [m_Data] = f_Get_Matrix2Plot(v_Elec,v_Feat,str_path2Load);

    %s = pcolor(m_Data);
    s = imagesc(m_Data);
    % s.FaceColor = 'interp';
    %set(gca, 'YDir','reverse')
    set(gca, 'CLim',[-1,1])
    colormap (m_Colormap)
    title('HFO electrodes','FontSize',14)
    %colorbar
    xticks(0.5:12.5)
    yticks(0.5:12.5)
    grid on

    f1 = gcf;
    ax1 = gca;
    set(f1,'Position',[482 225.5 740 597])
    %set(ax1,'Position',[0.04,0.05,0.8,0.9])
    set(f1,'Color','w')
    ax1.XTickLabel = [];
    ax1.YTickLabel = [];

    str_Name2Save = strcat('./',str_Feat,'/',num2str(i),'_',str_Feat,'.png');

    F = getframe(f1);
    [X, Map] = frame2im(F);
    imwrite(X,str_Name2Save)
    close (f1)
    
end

%% Early,late electrodes

m_ColormapEL = [
    1.0, 1.0, 1.0;  % Blanco para -1
    1.0, 1.0, 1.0;  % Blanco para 0
    0.0, 0.0, 1;    % Azul para 1
    1.0, 0.9725, 0.8627;  % Amarillo para 2
    1.0, 0.0, 0.0;  % Rojo para 3
];
str_Feat = 'EALT';
mkdir(str_Feat)

for i=1:s_NumFra

    v_Elec = stru_Sort_PID(i).Elec;
    v_Feat = stru_Sort_PID(i).EarLate;
    [m_Data] = f_Get_Matrix2Plot(v_Elec,v_Feat,str_path2Load);

    %s = pcolor(m_Data);
    s = imagesc(m_Data);
    % s.FaceColor = 'interp';
    %set(gca, 'YDir','reverse')
    set(gca, 'CLim',[-1,3])
    colormap (m_ColormapEL)
    title('Early-late electrodes','FontSize',14)
    %colorbar
    xticks(0.5:12.5)
    yticks(0.5:12.5)
    grid on

    f1 = gcf;
    ax1 = gca;
    set(f1,'Position',[482 225.5 740 597])
    %set(ax1,'Position',[0.04,0.05,0.8,0.9])
    set(f1,'Color','w')
    ax1.XTickLabel = [];
    ax1.YTickLabel = [];

    str_Name2Save = strcat('./',str_Feat,'/',num2str(i),'_',str_Feat,'.png');

    F = getframe(f1);
    [X, Map] = frame2im(F);
    imwrite(X,str_Name2Save)
    close (f1)
    
end

%% Generate v_Clasi to select the plots

v_TS_periods = [stru_FolderNames(ii).BU,stru_FolderNames(ii).SS,stru_FolderNames(ii).TG];
v_ClasiTS = [];

for i=1:s_NumFra

    v_Times = stru_Sort_PID(i).Indx;
    s_Max = max(v_Times);

    if s_Max<v_TS_periods(2)
        s_Save = 1;
    elseif s_Max>=v_TS_periods(2) && s_Max<v_TS_periods(3)
        s_Save = 2;
    elseif s_Max>=v_TS_periods(3)
        s_Save = 3;
    end

    v_ClasiTS(i) =s_Save;

end

% 1   BU
% 115 SS
% 302 TG

%% PID ocurrence

str_Feat = 'PID';
mkdir(str_Feat)

for i=1:s_NumFra

    v_Elec = stru_Sort_PID(i).Elec;
    v_Feat = stru_Sort_PID(i).PIDOcu;
    [m_Data] = f_Get_Matrix2Plot(v_Elec,v_Feat,str_path2Load);

    %s = pcolor(m_Data);
    s = imagesc(m_Data);
    % s.FaceColor = 'interp';
    %set(gca, 'YDir','reverse')
    set(gca, 'CLim',[-1,1])
    colormap (m_Colormap)
    title('PID electrodes','FontSize',14)
    %colorbar
    xticks(0.5:12.5)
    yticks(0.5:12.5)
    grid on

    f1 = gcf;
    ax1 = gca;
    set(f1,'Position',[482 225.5 740 597])
    %set(ax1,'Position',[0.04,0.05,0.8,0.9])
    set(f1,'Color','w')
    ax1.XTickLabel = [];
    ax1.YTickLabel = [];
    
    if v_ClasiTS(i)==1
        str_Period = 'Build up';
    elseif v_ClasiTS(i)==2
        str_Period = 'Steady state';
    elseif v_ClasiTS(i)==3
        str_Period = 'Trigger';
    end

    text(-1,13.5,str_Period,'FontSize',15,'Color','m')

    str_Name2Save = strcat('./',str_Feat,'/',num2str(i),'_',str_Feat,'.png');

    F = getframe(f1);
    [X, Map] = frame2im(F);
    imwrite(X,str_Name2Save)
    close (f1)
    
end
