%% Cleaning
clear; close all; clc

str_DataPath = 'C:\Users\david\Desktop\All_Data_Correc\Data\';
load('Names.mat')

%% Computing average
% for ii = 1:numel(stru_FolderNames)
% 
%     str_SliceName = strcat(stru_FolderNames(ii).Slice,'\');
%     load(strcat(str_DataPath,str_SliceName,'Peaks.mat'),'stru_Pks')
% 
%     m_Data = [];
% 
%     for jj =1:numel(stru_Pks)
% 
%         v_Pks = stru_Pks(jj).PksIndx;
% 
%         if isempty(v_Pks)
%             continue
%         else
%             load(strcat(str_DataPath,str_SliceName,'E',num2str(jj),'.mat'),'v_RawData')
%             m_Data = [m_Data;v_RawData];
%         end
% 
%     end
% 
%     v_RawData = mean(m_Data);
% 
%     save(strcat('E',num2str(ii),'.mat'),'v_RawData')
%     v_RawData = [];
% 
% end
% 
% %% Join Pks (after perform pks detection in the average signals)
% 
% stru_PksAve = [];
% 
% for kk =1:numel(stru_FolderNames)
% 
%     load(strcat('./pks_concu/E',num2str(kk),'_Pks.mat'),'v_Indx')
%     stru_PksAve(kk).PksAve = v_Indx;
% end
% 
% save('PksConcu.mat','stru_PksAve')

%% Concurrent events detection

ii = 18;

str_SliceName = strcat(stru_FolderNames(ii).Slice,'\');
load(strcat(str_DataPath,str_SliceName,'Peaks.mat'),'stru_Pks')            % Load all PID pks.

load('PksConcu.mat','stru_PksAve')                                         % Load avg pks.
v_Indx = stru_PksAve(ii).PksAve;

% Create a single matrix with all the PID peaks that are inside the centered window

s_Win = 1600;                                                              % 160 ms

% Verificar tamano ventana con un plot

% load(strcat(str_DataPath,str_SliceName,'E36.mat'),'v_FilData')
% plot(v_FilData(v_Indx(315)-(s_Win/2):v_Indx(315)+(s_Win/2)))
% figure
% v_Pte = stru_Pks(36).PksIndx;
% plot(v_FilData(v_Pte(10)-(s_Win/2):v_Pte(10)+(s_Win/2)))

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

%% Sort peaks and save the electrodes that fires first and last (5%)

s_Ac_Elec = numel(stru_Pks)-sum(arrayfun(@(x) isempty(x.PksIndx), stru_Pks));
s_5Per_Act = round(s_Ac_Elec*0.05);

v_Big_Bag_E = [];
v_Big_Bag_L = [];

for d=1:size(m_Indx_Pks_win,2)

    v_Frame = m_Indx_Pks_win(:,d);
    s_numNaN = sum(isnan(v_Frame));
    s_Act = numel(v_Frame)-s_numNaN;

    if s_Act< 3*s_5Per_Act
        continue
    else

        [a,b] = sort(v_Frame);
        b(isnan(a))=[];
        %a(isnan(a))=[];

        v_Bag_Early = b(1:s_5Per_Act);
        v_Bag_Late  = b(end-s_5Per_Act+1:end);

        v_Big_Bag_E = [v_Big_Bag_E;v_Bag_Early];
        v_Big_Bag_L = [v_Big_Bag_L;v_Bag_Late];
        
    end

end

figure()
s_counts_E = histcounts(v_Big_Bag_E, 1:121);
bar(1:120, s_counts_E,'r');
figure()
s_counts_L = histcounts(v_Big_Bag_L, 1:121);
bar(1:120, s_counts_L,'b');

% Plot surface

v_Active = [];
con = 1;

for z=1:numel(stru_Pks)
    v_P = stru_Pks(z).PksIndx;
    if isempty(v_P)
        continue
    else
        v_Active(con)= z;
        con = con+1;
    end
end

[~, v_top_5_E] = sort(s_counts_E, 'descend');
v_Early = v_top_5_E(1:s_5Per_Act);

[~, v_top_5_L] = sort(s_counts_L, 'descend');
v_Late = v_top_5_L(1:s_5Per_Act);

f_Plot_Surface(v_Early,v_Late,v_Active,strcat(str_DataPath,str_SliceName))
f= gcf;
str_NameSave = strcat(str_SliceName(1:end-1),'.png');
exportgraphics(gcf, str_NameSave, 'BackgroundColor', 'w')
%% Detect a time reference, same for each pk
% 
% s_SizeDe = 2000;
% v_J = [];
% 
% for i=1:size(m_Indx_Pks_win,1)
% 
%     str_Load = strcat(str_path2Load,'\E',num2str(i),'.mat');
%     load(str_Load,'v_FilData')
% 
%     for j=1:size(m_Indx_Pks_win,2)
% 
%         s_Indx = m_Indx_Pks_win(i,j);
% 
%         if isnan(s_Indx)
%             m_New_Indx(i,j) = s_Indx;
%         else
% 
%             [s_Beg] = f_AccuBegining(v_FilData,s_Indx);
%             m_New_Indx(i,j) = s_Beg;
% 
% %             v_Seg = v_FilData(s_Beg-s_SizeDe:s_Beg+s_SizeDe);
% %             figure()
% %             plot(v_Seg,'b')
% %             hold on
% %             xline(floor(numel(v_Fil)/2)+1,'m')           
% 
%         end
% 
%     end
% end


%% Take each frame, remove those with NaN and sort Pks
% 
% cont = 0;
% 
% for d=1:size(m_New_Indx,2)
% 
%     v_Frame = m_New_Indx(:,d);
%     s_numNaN = sum(isnan(v_Frame));
% 
%     if s_numNaN>= 115
%         continue
%     else
% 
%         [v_Indx,v_Elec] = sort(v_Frame);
%         s_NaN = find(isnan(v_Indx),1);
%         v_Indx(s_NaN:end)=[];
%         v_Elec(s_NaN:end)=[];
%         cont = cont+1;
% 
%         stru_Sort_PID(cont).Indx = v_Indx;
%         stru_Sort_PID(cont).Elec = v_Elec;
% 
%     end
% 
% end
% 
% save('stru_Sort.mat','stru_Sort_PID')
