%% Cleaning
clear; close all; clc

str_DataPath = 'C:\Users\david\Desktop\All_Data\Data\';
load('Names.mat')

%% Concurrent events detection

ii = 16;

str_SliceName = strcat(stru_FolderNames(ii).Slice,'\');
load(strcat(str_DataPath,str_SliceName,'Peaks.mat'),'stru_Pks')            % Load all PID pks.

load(strcat(str_DataPath,str_SliceName,'E1.mat'),'v_FilData')              % Load one electrode.
s_NumelSamp = numel(v_FilData);
clear v_FilData

s_Win = 1600;                                                              % 160 ms
v_Lims = 1:s_Win:s_NumelSamp;

% Create a single matrix with all the PID peaks that are inside the centered window

for i = 1:numel(v_Lims)-1

    s_LimInf = v_Lims(i);
    s_LimSup = v_Lims(i+1)-1;

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
        stru_Sort_PID(cont).PIDOcu = ones(numel(v_Elec),1);

    end

end

%% Get features

s_SizeDe = 2000;

% HFAs occurrence

str_L2 = strcat(str_DataPath,str_SliceName,'PksHFA.mat');
load(str_L2,'stru_HFA')

for i=1:size(stru_Sort_PID,2)

    v_ElecTemp =stru_Sort_PID(i).Elec;
    v_IndxTemp =stru_Sort_PID(i).Indx;

    v_HFAOCu =[];
    
    for k=1:numel(v_ElecTemp)

        s_Elec = v_ElecTemp(k);
        s_Indx = v_IndxTemp(k);

        v_TS_HFA = stru_HFA(s_Elec).PksIndx;

        if isempty(v_TS_HFA)
            
            v_HFAOCu(k,1) = 0;
            continue

        else
       
            v_Diff = abs(v_TS_HFA-s_Indx);

            if min(v_Diff) < s_SizeDe 
                
                v_HFAOCu(k,1) = 1;
            else
                v_HFAOCu(k,1) = 0;
            end

        end

    end

    stru_Sort_PID(i).HFAOcu = v_HFAOCu;
    
end

% HFOs occurrence

str_L2 = strcat(str_DataPath,str_SliceName,'Candidates_HFO.mat');
load(str_L2,'struHFO')

for i=1:size(stru_Sort_PID,2)

    v_ElecTemp =stru_Sort_PID(i).Elec;
    v_IndxTemp =stru_Sort_PID(i).Indx;

    v_HFOOCu =[];
    
    for k=1:numel(v_ElecTemp)

        s_Elec = v_ElecTemp(k);
        s_Indx = v_IndxTemp(k);

        m_TS_HFO = struHFO(s_Elec).m_HFOCandidates;

        if isempty(m_TS_HFO)
            
            v_HFOOCu(k,1) = 0;
            continue

        else
            v_is_HFO = struHFO(s_Elec).VisualInspec_Final;
            v_TS_HFO = m_TS_HFO(v_is_HFO==1,1);

            v_Diff = abs(v_TS_HFO-s_Indx);

            if min(v_Diff) < s_SizeDe 
                
                v_HFOOCu(k,1) = 1;
            else
                v_HFOOCu(k,1) = 0;
            end

        end

    end

    stru_Sort_PID(i).HFOOcu = v_HFOOCu;
    
end

% Amplitude of the LPF 
m_AllData = [];
for zz = 1:120
    load(strcat(str_DataPath,str_SliceName,'E',num2str(zz),'.mat'),...
            'v_FilData');
    m_AllData(zz,:) = v_FilData;
end

for i=1:size(stru_Sort_PID,2)

    v_ElecTemp =stru_Sort_PID(i).Elec;
    v_IndxTemp =stru_Sort_PID(i).Indx;

    v_PIDAmp =[];

    for j=1:numel(v_ElecTemp)

        s_Elec = v_ElecTemp(j);
        s_Indx = v_IndxTemp(j);
        v_PIDAmp(j,1) = m_AllData(s_Elec,s_Indx);       

    end

    stru_Sort_PID(i).PIDAmp = abs(v_PIDAmp);
   
end

% Early, late discharges

for z=1:numel(stru_Sort_PID)

    v_Clasi = [];
    v_Active = stru_Sort_PID(z).Elec;
    s_5Per_Act = round(0.05*numel(v_Active));
    v_Clasi = 2*ones(numel(v_Active),1);
    v_Clasi(1:s_5Per_Act)= 3;
    v_Clasi(end-s_5Per_Act+1:end)= 1;

    stru_Sort_PID(z).EarLate = v_Clasi;    

end

save('Features2Plot_Win.mat','stru_Sort_PID')