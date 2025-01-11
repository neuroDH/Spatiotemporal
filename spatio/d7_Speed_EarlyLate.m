% Speed between early and late

%% Cleaning

clear; close all; clc

str_DataPath = 'C:\Users\david\Desktop\All_Data\Data\';
load('Names.mat')

v_Slices = [9,14,15,16,17,18,25];

ii = 6;

%% Concurrent events detection

str_SliceName = strcat(stru_FolderNames(v_Slices(ii)).Slice,'\');
load(strcat(str_DataPath,str_SliceName,'Peaks.mat'),'stru_Pks')            % Load all PID pks.

load('PksConcu.mat','stru_PksAve')                                         % Load avg pks.
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
%% Early and late areas detection (using all time)

v_All_Early = [];
v_All_Late = [];

s_NumEleEL = 5;                                                            % Numero de electrodos a detectar

for i=1:numel(stru_Sort_PID)

    v_TempElec = stru_Sort_PID(i).Elec;
    s_NumEle = round(0.1*numel(v_TempElec));
    v_Early = v_TempElec(1:s_NumEle);
    v_Late = v_TempElec(end-s_NumEle+1:end);

    v_All_Early = [v_All_Early;v_Early];
    v_All_Late = [v_All_Late;v_Late];

end

[a,~] = histcounts(v_All_Early,1:121);
[~,b]=sort(a,'descend');
v_El_Ear = b(1:s_NumEleEL);

[c,~] = histcounts(v_All_Late,1:121);
[~,d]=sort(c,'descend');
v_El_Lat = d(1:s_NumEleEL);

%% Compute speed (between early electrodes)

str_A = 'Ear'; % Ear, Lat
%str_A = 'Lat'; % Ear, Lat

if strcmp(str_A,'Ear')

    v_Use = v_El_Ear;

elseif strcmp(str_A,'Lat')

    v_Use = v_El_Lat;

end

% Average of early electrodes and peaks detection

for i=1:numel(v_Use)
    
    str_Ele = num2str(v_Use(i));
    load(strcat(str_DataPath,str_SliceName,'E',str_Ele,'.mat'),'v_RawData')
    m_Data(i,:) = v_RawData;

end

s_SampRate = 10000;
v_RawData = mean(m_Data);
save('./TempPeaks/E1.mat','v_RawData','s_SampRate')
a1_main_PID_tresh(0)

%%
clc
movefile ./E1_Pks.mat ./TempPeaks/E1_Pks.mat
load('./TempPeaks/E1_Pks.mat','v_Indx')

%% Concurrent events detection
                                                                           % Create a single matrix with all the PID peaks that are inside the centered window
s_Win = 1600;                                                              % 160 ms
m_Indx_Pks_win = [];

for i = 1:numel(v_Indx)

    s_LimInf = v_Indx(i)-(s_Win/2);
    s_LimSup = v_Indx(i)+(s_Win/2);

    v_Pk_Indx = [];

    for j=1:numel(v_Use)

        v_PksTemp = stru_Pks(v_Use(j)).PksIndx;
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

% Take each frame, remove those with NaN and sort Pks

stru_Sort_PID = [];
m_New_Indx = m_Indx_Pks_win;
cont = 0;

for d=1:size(m_New_Indx,2)

    v_Frame = m_New_Indx(:,d);
    s_numNaN = sum(isnan(v_Frame));

    if s_numNaN>= 2
        continue
    else

        [v_Indx,v_Elec] = sort(v_Frame);
        s_NaN = find(isnan(v_Indx),1);
        v_Indx(s_NaN:end)=[];
        v_Elec(s_NaN:end)=[];
        cont = cont+1;

        stru_Sort_PID(cont).Indx = v_Indx;
        stru_Sort_PID(cont).Elec = v_Elec;
        stru_Sort_PID(cont).TimeRef = [v_Indx(1)];

    end

end

%
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

for i = 1:numel(stru_Sort_PID)

    v_Elec = v_El_Ear(stru_Sort_PID(i).Elec);
    v_Time = stru_Sort_PID(i).Indx;
    cont=1;
    v_Tdiff_Tem = [];
    v_D_Tem=[];

    for j = 1:numel(v_Elec)-1
        
        s_C_Elec = v_Elec(j);
        s_N_Elec = v_Elec(j+1);

        [a,b] = find(m_IndxOri==s_C_Elec);
        [c,d] = find(m_IndxOri==s_N_Elec);

        s_X2 = (m_X(a,b)-m_X(c,d))^2;
        s_Y2 = (m_Y(a,b)-m_Y(c,d))^2;

        s_Dist_mm = sqrt(s_X2+s_Y2);
        s_Dist_m = s_Dist_mm/1000;

        if s_Dist_mm<= 0.4
            
            v_Tdiff_Tem(cont) = (v_Time(j+1)-v_Time(j))/10000;
            v_D_Tem(cont) = s_Dist_m;
            cont = cont+1;
        end        

    end

    v_D_Tem(v_Tdiff_Tem==0)=[];
    v_Tdiff_Tem(v_Tdiff_Tem==0)=[];
    v_Speed(i) = mean(v_D_Tem./v_Tdiff_Tem);   

end

%v_Speed(isnan(v_Speed)) = [];
%

load('Speed_E_L.mat','stru_Speed')

if strcmp(str_A,'Ear')

    stru_Speed(ii).Early.Speed = v_Speed;
    stru_Speed(ii).Early.TimeRef = [stru_Sort_PID.TimeRef];
    stru_Speed(ii).Early.Electrodes = v_Use;

elseif strcmp(str_A,'Lat')

    stru_Speed(ii).Late.Speed = v_Speed;
    stru_Speed(ii).Late.TimeRef = [stru_Sort_PID.TimeRef];
    stru_Speed(ii).Late.Electrodes = v_Use;

end

save('Speed_E_L.mat','stru_Speed')

%% Plot 

load('Speed_E_L.mat','stru_Speed')
jj = 6; %7
v_Lims = [0,3];

v_Ear = stru_Speed(jj).Early.Electrodes;
v_Lat = stru_Speed(jj).Late.Electrodes;

v_SpeedEar = stru_Speed(jj).Early.Speed;
v_SpeedLat = stru_Speed(jj).Late.Speed;
v_TimeEar = stru_Speed(jj).Early.TimeRef;
v_TimeLat = stru_Speed(jj).Late.TimeRef;

v_DelEar = isnan(v_SpeedEar);
v_DelLat = isnan(v_SpeedLat);

v_TimeEar(v_DelEar) = [];
v_SpeedEar(v_DelEar) = [];
v_TimeLat(v_DelLat) = [];
v_SpeedLat(v_DelLat) = [];

% Plot areas

m_ColormapEL = [
    1.0, 1.0, 1.0;  % Blanco para -1
    1.0, 1.0, 1.0;  % Blanco para 0
    0.0, 0.0, 1;    % Azul para 1
    1.0, 0.9725, 0.8627;  % Amarillo para 2
    1.0, 0.0, 0.0;  % Rojo para 3
];

v_Elec = 1:120;
v_Feat = 2*ones(1,120);
v_Feat(v_Ear) = 3;
v_Feat(v_Lat) = 1;

[m_Data] = f_Get_Matrix2Plot(v_Elec,v_Feat,strcat(str_DataPath,str_SliceName));

s = imagesc(m_Data);
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
set(f1,'Color','w')
ax1.XTickLabel = [];
ax1.YTickLabel = [];

F1 = getframe(f1);
[X1, Map] = frame2im(F1);

% X
% imwrite(X,str_Name2Save)
close (f1)

% Plot Speed Early

s_Siz = 14;

f2 = figure('Position',[1527 353 740 597.20],'Color','white');
plot(v_TimeEar./10000,v_SpeedEar,'r','LineWidth',1)
title('Speed early regions')
ylabel('speed (m/s)','FontSize', s_Siz)
xlabel('time (s)','FontSize', s_Siz)
ax = gca;
set(ax, 'FontSize', s_Siz);
ylim(v_Lims)

F2 = getframe(f2);
[X2, Map] = frame2im(F2);
close (f2)

% Plot Speed Late

s_Siz = 14;
f3 = figure('Position',[1527 353 740 597.20],'Color','white');
plot(v_TimeLat./10000,v_SpeedLat,'b','LineWidth',1)
title('Speed late regions')
ylabel('speed (m/s)','FontSize', s_Siz)
xlabel('time (s)','FontSize', s_Siz)
ylim(v_Lims)
ax = gca;
set(ax, 'FontSize', s_Siz);

F3 = getframe(f3);
[X3, Map] = frame2im(F3);
close (f3)

m_Image = [X1,X2,X3];
imshow(m_Image)

%% Bins

load('Speed_E_L.mat','stru_Speed')
s_Bin = 23;
s_Sz = 14;

for h=1:7

    v_Y = stru_Speed(h).Late.Speed;
    v_X = stru_Speed(h).Late.TimeRef;

    v_DelEar = isnan(v_Y);

    v_Y(v_DelEar) = [];
    v_X(v_DelEar) = [];

    v_X_Nor = (v_X-min(v_X))/(max(v_X)-min(v_X));                          % Normalization
    %plot(v_X_Nor,v_Y,'.')
    % plot(v_X_Nor,v_Y)
    % hold on

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
title('speed early','FontSize',s_Sz)
% ylim([0,0.045])

[p_t,~,stats] = friedman(m_mean_Bin);
figure()
c_t = multcompare(stats,'CriticalValueType','dunn-sidak');
title('No subperiods groups')

f_ImageMultiComp(c_t,0.05)
set(gca,'FontSize',s_Sz)