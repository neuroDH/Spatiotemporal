%% Cleaning
clear; close all; clc

%% Check that TS are good (first in PID electrodes)
load('PID_HFA.mat')

str_Data = './Data/';
for i=1:numel(stru_MergData)

    str_Slice = stru_MergData(i).Slice;
    str_Load = strcat(str_Data,str_Slice,'.mat');
    load(str_Load,'v_FilData')

    figure()
    v_Line = [stru_MergData(i).BU,stru_MergData(i).SS,stru_MergData(i).TG,stru_MergData(i).SO];
    plot(v_FilData)
    hold on
    xline(v_Line,'m')

end


%% Fin delay too cut using same time reference that PID

clear; close all; clc
load('HFO_BST.mat')
str_Data_Path = './Check_Elec/';
str_Data_Path2 = './Data/';

Nfir = 70;
Fst = 50;
firf = designfilt('lowpassfir','FilterOrder',Nfir, ...
    'CutoffFrequency',Fst,'SampleRate',10000);

for i=1:numel(stru_MergData)

    str_Slice = stru_MergData(i).Slice;
    str_FileNameDataRaw = strcat(str_Data_Path,str_Slice,'.raw');
    str_FileNameDataMat = strcat(str_Data_Path2,str_Slice,'.mat');
    
    [v_Data,stru_Header,s_NewSamRate] = f_ReadRawData(str_FileNameDataRaw,10000);
    load(str_FileNameDataMat,'v_FilData')

    v_FilData_l = filter(firf,v_Data);
    v_FilData_l = flip(filter(firf, flip(v_FilData_l)));

%     s_Del = abs(finddelay(v_FilData,v_FilData_l));

    figure()
    plot(v_FilData_l,'b')
    hold on
    plot(m_BU(1,i):m_BU(1,i)+numel(v_FilData)-1,v_FilData,'r')

    %m_BU(1,i) = s_Del;
    %m_BU(2,i) = s_Del+stru_MergData(i).SO-1;

end

save('HFO_ref.mat','m_BU')

%% Cut and save electrode data and get HFO TS (acording to reference)

clear; close all; clc
load('HFO_ref.mat','m_BU')
load('HFO_BST.mat')

str_Data_Path = './Check_Elec_HFO/';
str_Data_Path2 = './Data_HFO/';
str_Data_Path3 = 'C:\Users\david.henao\Desktop\All_Data_Correc\Data\';
str_Data_Path4 = './Data/';

load('HFO_BST.mat')
cll_Slice = {stru_MergData.Slice};

for i=1:numel(stru_MergData)

    load('HFO_BST.mat')
    str_Slice = stru_MergData(i).Slice;
    str_FileNameDataRaw = strcat(str_Data_Path,str_Slice,'.raw');
    str_FileNameDataMat = strcat(str_Data_Path2,str_Slice,'.mat');
    str_FileNameDataHFO = strcat(str_Data_Path3,str_Slice,'\','Candidates_HFO.mat');
    
    [v_RawData,~,s_SampRate] = f_ReadRawData(str_FileNameDataRaw,10000);
    Nfir = 70;
    Fst = 50;
    firf = designfilt('lowpassfir','FilterOrder',Nfir, ...
        'CutoffFrequency',Fst,'SampleRate',s_SampRate);
    v_Data = filter(firf,v_RawData);
    v_FilData = flip(filter(firf, flip(v_Data)));

    v_RawData = v_RawData(m_BU(1,i):m_BU(2,i));
    v_FilData = v_FilData(m_BU(1,i):m_BU(2,i));

    save(str_FileNameDataMat,'v_RawData','v_FilData','s_SampRate');

    % HFO ref
    s_Ele = stru_MergData(i).Electrode;
    load(str_FileNameDataHFO,'struHFO')

    m_Candi = struHFO(s_Ele).m_HFOCandidates;
    v_True = struHFO(s_Ele).VisualInspec_Final';
    v_True(isnan(v_True))=0;

    m_HFO = m_Candi(logical(v_True),:);

%     s_Val = m_BU(1,i);

    load(strcat(str_Data_Path4,str_Slice,'.mat'))
    v_DataHFA = v_FilData;

    load('PID_HFA.mat')
    cll_SliceHFA = {stru_MergData.Slice};
    s_IndEle = find(strcmp(cll_SliceHFA,str_Slice)==1);
    s_Ele = stru_MergData(s_IndEle).Elec;
    
    str_FileLoadMat = strcat(str_Data_Path3,str_Slice,'\E',num2str(s_Ele),'.mat');
    load(str_FileLoadMat,'v_FilData')
    v_Seg = v_FilData(m_HFO(1):m_HFO(end));
    s_Del = finddelay(v_Seg,v_DataHFA);

    figure()
    plot(v_DataHFA,'b')
    hold on
    plot(s_Del:s_Del+numel(v_Seg)-1,v_Seg,'r')

    %s_Val = abs(s_Del)-m_HFO(1);
    m_HFO = m_HFO-(m_HFO(1))+1 + s_Del; %Hay al;go mal en el delay y tambi hay que corregir el global delay del 11

    stru_HFOTS(i).Corrected = m_HFO;

end

save(strcat(str_Data_Path2,'TS_HFO.mat'),'stru_HFOTS','cll_Slice')

%% Accurate HFO TS

clear; close all; clc

i=8;

addpath('./functions')
load('./Data_HFO/TS_HFO.mat')
str_Slice = cll_Slice{i};
load(strcat('./Data_HFO/',str_Slice,'.mat'),'v_RawData')
load(strcat('./Data_HFO/',str_Slice,'.mat'),'v_FilData')

%% PID peaks
v_Pks = 1;
f_Detect_Peaks(v_Pks,v_RawData)

%% Or bypass pks and go to HFO

load('HFO_BST.mat')

v_Ini = stru_MergData(i).PID_B;
v_Fin = stru_MergData(i).PID_E;

v_Pks = [];

for d=1:numel(v_Ini)
    v_Seg = v_FilData(v_Ini(d):v_Fin(d));
    [~,b] = max((v_Seg));
    v_Pks(d) = v_Ini(d)+b;
end


plot(v_FilData,'b')
hold on
plot(v_Pks,v_FilData(v_Pks),'*k')

load('./Data_HFO/Peaks.mat','stru_Pks');
stru_Pks(i).PksIndx = v_Pks;
save('./Data_HFO/Peaks.mat','stru_Pks');


%% Save cor peaks
load('Temp_Pks.mat','v_Indx')
load('./Data_HFO/Peaks.mat','stru_Pks');
stru_Pks(i).PksIndx = v_Indx;
save('./Data_HFO/Peaks.mat','stru_Pks');

%% Correct PID TS

load('./Data_HFO/Peaks.mat','stru_Pks');
v_Indx = stru_Pks(i).PksIndx;

v_Idx_B = v_Indx-2000;
v_Idx_E = v_Indx+2000;


[v_corIdx_B,v_corIdx_E] = f_ManuallyCorrec_TS(v_FilData,v_Idx_B,v_Idx_E,[],'PID');

load('HFO_BST.mat')

stru_MergData(i).PID_B =v_corIdx_B;
stru_MergData(i).PID_E =v_corIdx_E;

% v_Idx_B = stru_MergData(i).PID_B;
% v_Idx_E = stru_MergData(i).PID_E;
% v_Idx_B = v_corIdx_B;
% v_Idx_E = v_corIdx_E;

save('HFO_BST.mat','stru_MergData')

%% Correct HFA TS
% 
% load('Temp_HFA_HFO.mat')
% 
% v_Idx_B = stru_MergData(i).PID_B;
% v_Idx_E = stru_MergData(i).PID_E;
% 
% [v_corIdx_B,v_corIdx_E] = f_ManuallyCorrec_TS(v_RawData,v_Idx_B,v_Idx_E,[],'HFA');
% 
% stru_MergData(i).HFA_B =v_corIdx_B;
% stru_MergData(i).HFA_E =v_corIdx_E;
% 
% save('Temp_HFA_HFO.mat','stru_MergData')

%% Correct HFO TS

m_HFO = stru_HFOTS(i).Corrected;
v_Idx_B = m_HFO(:,1);
v_Idx_E = m_HFO(:,2);

[v_corIdx_B,v_corIdx_E,v_Freq] = f_ManuallyCorrec_HFO(v_RawData,v_Idx_B,v_Idx_E);

load('HFO_BST.mat')

stru_MergData(i).HFO_B =v_corIdx_B;
stru_MergData(i).HFO_E =v_corIdx_E;
stru_MergData(i).HFO_F =v_Freq;

save('HFO_BST.mat','stru_MergData')

% graficar HFO con Cnadidates_Data (ahi esta toda la informacion)
% y comparar con lo que deberia ver sobre todo en los electrodos malucos
% 
% hacer una funcion que genere ambas graficas 
% 
% luego de que las HFO esten de acuerod a los TS guardados en Data_HFO 
% 
% finalmente volver a correr el algoritmo temporal de HFO (rapido)
% 
% luego algoritmo correlacion PID HFO
% 
% luego PHASE de ambos
%%
%clear;
%load('Comp.mat')

for i=1:10

    v_Raw = stru_Comp(i).v_RawSeg;
    v_Fil = stru_Comp(i).v_FilSeg;
    v_Hil = stru_Comp(i).v_HilSeg;
    v_Tim = stru_Comp(i).v_TimeSeg;
    m_Wav = stru_Comp(i).m_MorseSeg;
    v_Fre = stru_Comp(i).v_FreqAxis;
    v_TS = stru_Comp(i).v_TimeIniFin;

    f = figure();
    a = subplot(2,1,1);
    plot(v_Tim,v_Raw,'k','Color',[0.8,0.8,0.8])
    hold on
    plot(v_Tim,v_Fil,'b')
    plot(v_Tim,v_Hil,'r')
    xline(v_TS,'m')
    b = subplot(2,1,2);
    f_ImageMatrix(m_Wav,v_Tim, v_Fre, [],'hot',256);
    linkaxes([a,b],'x')

end

% s_SS = stru_MergData(i).SS;
% s_TG = stru_MergData(i).TG;
% 
% figure()
% plot(v_FilData,'b')
% hold on
% % plot(v_Beg,v_FilData(v_Beg),'*r')
% % plot(v_End,v_FilData(v_End),'*m')
% plot(v_Pks,v_FilData(v_Pks),'*k')
% xline([s_SS,s_TG],'k')


stru_Comp(~logical(v_T))=[];
v_T = struHFO(30).VisualInspec_Final;
v_T(isnan(v_T))=0;
logical(v_T)
stru_Comp(~logical(v_T))=[];
