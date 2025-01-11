%% Cleaning
clear; close all; clc

%% Loading
ddd=7;
ii = 25; % 14,15,16,17,18,9,25
load('Names.mat')
str_DataPath = 'C:\Users\david\Desktop\All_Data\Data\';

%% Concurrent events detection

str_SliceName = strcat(stru_FolderNames(ii).Slice,'\');
load(strcat(str_DataPath,str_SliceName,'Peaks.mat'),'stru_Pks')            % Load all PID pks.

load('PksConcu.mat','stru_PksAve')                                         % Load avg pks.
v_Indx = stru_PksAve(ii).PksAve;

% Create a single matrix with all the PID peaks that are inside the centered window

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

%% Verify repeated elements in the same row

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

%% Take each frame, remove those with NaN and sort Pks
m_New_Indx = m_Indx_Pks_win;
cont = 0;

for d=1:size(m_New_Indx,2)

    v_Frame = m_New_Indx(:,d);
    s_numNaN = sum(isnan(v_Frame));

    if s_numNaN>= 110
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

%% Compute the ideal windows size

% v_Time = [stru_Sort_PID.TimeRef];
% s_maxCategoryCount = 0;
% s_bestWindowSize = 0;
% s_bestStartIndex = 0;
% cont = 1;
% 
% for s_winSiz = 10000:500:100000
% 
%     for startIndex = 1:10:v_Time(end)-s_winSiz
% 
%         v_Edges = startIndex:s_winSiz:v_Time(end)+s_winSiz;
%         categories = discretize(v_Time, v_Edges);
%         categoryCount = histcounts(categories, 1:max(categories)+1);
% 
%         if max(categoryCount) > s_maxCategoryCount
%             s_maxCategoryCount = max(categoryCount);
%             s_bestWindowSize = s_winSiz;
%             s_bestStartIndex = startIndex;
%         end
%     end
% 
%     fprintf('Iteracion numero: %d de 181\n', cont);
%     cont = cont+1;
% end
% 
% fprintf('El mejor tamaño de ventana es: %d segundos\n', s_bestWindowSize);
% fprintf('La mejor posición de inicio es: %d\n', s_bestStartIndex);
% 
% % El mejor tamaño de ventana es: 86000 segundos
% % La mejor posición de inicio es: 18981

%%
load('NumIter.mat','m_Iter')
v_Aux = m_Iter(:,3);
s_IAux = find(v_Aux==ii);
s_bestWindowSize = m_Iter(s_IAux,1);
s_bestStartIndex = m_Iter(s_IAux,2);
s_RefEnd = stru_Sort_PID(numel(stru_Sort_PID)).TimeRef;
s_Win = s_bestWindowSize;
s_LimInf = s_bestStartIndex;
cont = 1;
m_Inter = [];

while (s_LimInf<=s_RefEnd)

    m_Inter(cont,:) = [s_LimInf,s_LimInf+s_Win,cont];
    cont = cont+1;
    s_LimInf = s_LimInf+ s_Win+1;
end

for i=1:numel(stru_Sort_PID)
    s_IndxEval = stru_Sort_PID(i).TimeRef;
    for j=1:numel(m_Inter)/3
        s_I = m_Inter(j,1);
        s_S = m_Inter(j,2);
        s_C = m_Inter(j,3);
        if s_IndxEval>= s_I && s_IndxEval<= s_S
            stru_Sort_PID(i).ClasiG = s_C;
            break
        end
    end

end

% v_Edges = s_LimInf:s_Win:v_Time(end)+s_winSiz;
% categories = discretize(v_Time, v_Edges);
% categoryCount = histcounts(categories, 1:max(categories)+1)';

%% Elimina filas con un solo evento concurrente por categoria

v_Categories = [stru_Sort_PID.ClasiG];
v_HisCount = histcounts(v_Categories, 1:max(v_Categories)+1);

cont = 1;
m_SaveDel = [];
for i=1:numel(v_HisCount)
    if v_HisCount(i)==1
        m_SaveDel(cont,:)=(v_Categories==i);
        cont = cont+1;
    end
end

v_Del = sum(m_SaveDel)==1;
stru_Sort_PID(v_Del)=[];
%stru_Sort_PID(1)=[];

%% Calcula los electrodos early y late por categoria

v_All_Early = [];
v_All_Late = [];
v_All_Elec = [];
m_Frames = [];
s_ClasiPrev = stru_Sort_PID(1).ClasiG;
v_TempIndx = stru_Sort_PID(1).Indx;
s_IniTime = v_TempIndx(1);
cont = 1;

s_NumEleEL = 3;                                                            % Cambio belen

for i=1:numel(stru_Sort_PID)

    s_CurrClasi = stru_Sort_PID(i).ClasiG;
    v_TempElec = stru_Sort_PID(i).Elec;
    v_TempIndx = stru_Sort_PID(i).Indx;
    s_NumEle = round(0.1*numel(v_TempElec));
    v_Early = v_TempElec(1:s_NumEle);
    v_Late = v_TempElec(end-s_NumEle+1:end);

    if s_CurrClasi~= s_ClasiPrev
        %Extraer electrodos early y late y guardarlos junto a las timestamps

        % Early
        v_Counts_Ear = histcounts(v_All_Early, 1:121);
        [~, sortedIndices] = sort(v_Counts_Ear, 'descend');
        top6Values_E = sortedIndices(1:s_NumEleEL);                                

        % Late
        v_Counts_Late = histcounts(v_All_Late, 1:121);
        [~, sortedIndices] = sort(v_Counts_Late, 'descend');
        top6Values_L = sortedIndices(1:s_NumEleEL);                              

        v_AuxIndx = stru_Sort_PID(i-1).Indx;
        s_FinTime = v_AuxIndx(end);
        m_Frames(cont,:) = [s_IniTime,s_FinTime,top6Values_E,top6Values_L];
        
        v_Elec_Temp = unique(v_All_Elec);
        v_EaLat_Temp = 2*ones(numel(unique(v_All_Elec)),1);

        v_EaLat_Temp(sum(v_Elec_Temp == top6Values_E,2)==1)=3;
        v_EaLat_Temp(sum(v_Elec_Temp == top6Values_L,2)==1)=1;

        stru_Plot_EL(cont).Elec = v_Elec_Temp;
        stru_Plot_EL(cont).EaLt = v_EaLat_Temp;

        s_IniTime = v_TempIndx(1);
        cont = cont+1;
        s_ClasiPrev = s_CurrClasi;
        v_All_Early = [];
        v_All_Late = [];
        v_All_Elec = [];
        
    end

    v_All_Early = [v_All_Early;v_Early];
    v_All_Late = [v_All_Late;v_Late];
    v_All_Elec = [v_All_Elec;v_TempElec];

end

%% Plotear las areas y video 
% 
% m_ColormapEL = [
%     1.0, 1.0, 1.0;  % Blanco para -1
%     1.0, 1.0, 1.0;  % Blanco para 0
%     0.0, 0.0, 1;    % Azul para 1
%     1.0, 0.9725, 0.8627;  % Amarillo para 2
%     1.0, 0.0, 0.0;  % Rojo para 3
% ];
% 
% s_NumFra = numel(stru_Plot_EL);
% 
% str_Feat = 'EALT';
% mkdir(str_Feat)
% 
% for i=1:s_NumFra
% 
%     v_Elec = stru_Plot_EL(i).Elec;
%     v_Feat = stru_Plot_EL(i).EaLt;
%     [m_Data] = f_Get_Matrix2Plot(v_Elec,v_Feat,strcat(str_DataPath,str_SliceName));
% 
%     %s = pcolor(m_Data);
%     s = imagesc(m_Data);
%     % s.FaceColor = 'interp';
%     %set(gca, 'YDir','reverse')
%     set(gca, 'CLim',[-1,3])
%     colormap (m_ColormapEL)
%     title('Early-late electrodes','FontSize',14)
%     %colorbar
%     xticks(0.5:12.5)
%     yticks(0.5:12.5)
%     grid on
% 
%     yline([4.5,8.5],'k','LineWidth',1.5)
%     xline([3.5,6.5,9.5],'k','LineWidth',1.5)
% 
%     f1 = gcf;
%     ax1 = gca;
%     set(f1,'Position',[482 225.5 740 597])
%     %set(ax1,'Position',[0.04,0.05,0.8,0.9])
%     set(f1,'Color','w')
%     ax1.XTickLabel = [];
%     ax1.YTickLabel = [];
% 
%     str_Name2Save = strcat('./',str_Feat,'/',num2str(i),'_',str_Feat,'.png');
% 
%     F = getframe(f1);
%     [X, Map] = frame2im(F);
%     imwrite(X,str_Name2Save)
%     close (f1)
% 
% end

%% Score de propagacion

load('Stru_Score.mat','stru_Score')
s_NumFra = numel(stru_Plot_EL);

for i=2:s_NumFra

    % Previous frame

    v_Elec = stru_Plot_EL(i-1).Elec;
    v_Feat = stru_Plot_EL(i-1).EaLt;
    
    v_Feat(v_Feat==2) = 0; % Always
    v_Feat(v_Feat==1) = 0; % Because we are analizing early
    v_Feat(v_Feat==3) = 1; % To analize early

    [m_Data_p] = f_Get_Matrix2Plot(v_Elec,v_Feat,strcat(str_DataPath,str_SliceName));

    v_AcPre = f_GetActiveAreas(m_Data_p,stru_Score);

    % Current frame
    
    v_Elec = stru_Plot_EL(i).Elec;
    v_Feat = stru_Plot_EL(i).EaLt;
    
    v_Feat(v_Feat==2) = 0; % Always
    v_Feat(v_Feat==1) = 0; % Because we are analizing early
    v_Feat(v_Feat==3) = 1; % To analize early

    [m_Data_c] = f_Get_Matrix2Plot(v_Elec,v_Feat,strcat(str_DataPath,str_SliceName));

    %v_AcCur = f_GetActiveAreas(m_Data,stru_Score);

    v_Sum = [];

    for j = 1:numel(v_AcPre)
        s_Ap = v_AcPre(j);
        m_Score = stru_Score(s_Ap).AreasScore.*m_Data_c;
        v_Sum(1,j) = sum(sum(m_Score,'omitmissing'))/s_NumEleEL;
    end

    v_Score(i,1) = mean(v_Sum);

end

load('v_Score.mat','stru_VScore')
stru_VScore(ddd).Score = v_Score;
save('v_Score.mat','stru_VScore')