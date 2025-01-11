%% Cleaning
clear; close all; clc;

%% Load and plot

str_Path = 'C:\Users\david\Desktop\All_Data\Data\';
load('Names.mat')

i = 8; % Slice

str_SliceName = stru_FolderNames(i).Slice;

str_HFOLoad = strcat(str_Path,str_SliceName,'\Candidates_HFO.mat');
load(str_HFOLoad)
%%
j = 57; % Electrode with HFOs

v_Is_HFO = [struHFO(j).VisualInspec_Final]==1;

m_TS_HFO = struHFO(j).m_HFOCandidates;
stru_Data_HFO = struHFO(j).m_HFOCandidatesData;

m_TS_HFO (~v_Is_HFO,:)= [];
stru_Data_HFO (~v_Is_HFO)= [];
load(strcat(str_Path,str_SliceName,'\E',num2str(j),'.mat'),'v_RawData')

% Wavelet parameters

s_MinFreqHz = 55;
s_MaxFreqHz = 500;
s_FreqSeg = 60;
s_NumOfCycles = 1.5;
s_Magnitudes = 1;
s_SquaredMag = 0;
s_MakeBandAve = 0;
s_Phases = 0;
s_TimeStep = [];

%%
for k =1:numel(stru_Data_HFO)

    v_Raw = stru_Data_HFO(k).v_RawSeg;
    v_Fil = stru_Data_HFO(k).v_FilSeg;
    v_Tim = stru_Data_HFO(k).v_TimeSeg;
    m_Wav = stru_Data_HFO(k).m_MorseSeg;
    v_Fre = stru_Data_HFO(k).v_FreqAxis;
    v_Lin = stru_Data_HFO(k).v_TimeIniFin;

    figure()

    subplot(2,2,1)
    plot(v_Tim,v_Raw,'k')
    hold on
    plot(v_Tim,v_Fil,'b')
    xline(v_Lin,'m')
    subplot(2,2,3)
    f_ImageMatrix(m_Wav, v_Tim, v_Fre, [],'hot',256);
    hold on
    xline(v_Lin,'g')

    v_GTS = m_TS_HFO(k,:);
    v_Raw2 = v_RawData(v_GTS(1)-2000:v_GTS(2)+2000);
    v_Tim2 = [0:numel(v_Raw2)-1]./10000;
    v_Lin2 = [2001,numel(v_Raw2)-2000]./10000;
    [m_Wav2,~,v_Fre2] = ...
        f_MorseAWTransformMatlab(...
        v_Raw2, ...
        10000, ...
        s_MinFreqHz, ...
        s_MaxFreqHz, ...
        s_FreqSeg, ...
        s_NumOfCycles, ...
        s_Magnitudes, ...
        s_SquaredMag, ...
        s_MakeBandAve, ...
        s_Phases, ...
        s_TimeStep);

    subplot(2,2,2)
    plot(v_Tim2,v_Raw2,'k')
    hold on
    xline(v_Lin2,'m')
    subplot(2,2,4)
    f_ImageMatrix(m_Wav2, v_Tim2, v_Fre2, [],'hot',256);
    hold on
    xline(v_Lin2,'g')
end