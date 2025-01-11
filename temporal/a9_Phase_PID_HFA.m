%% Cleaning

clear; close all; clc;

%% loading

load ('PID_HFA.mat')
addpath('./functions')

%%

xx = 18;
s_SampRate = 10000;

s_BU = stru_MergData(xx).BU;
s_SS = stru_MergData(xx).SS;
s_TG = stru_MergData(xx).TG;
s_SO = stru_MergData(xx).SO;

% Extraer PID asociadas con una HFA guardar estas PID y sus respectivas HFAs en una sola matriz

v_PIDB = stru_MergData(xx).PID_B;
v_PIDE = stru_MergData(xx).PID_E;
v_HFAB = stru_MergData(xx).HFA_B;
v_HFAE = stru_MergData(xx).HFA_E;

[v_Idx_PID,v_Idx_PID_No,v_Idx_Aso] = f_Asocia_PID_HFA(v_PIDB,v_PIDE,v_HFAB,v_HFAE);

m_Aso(:,1) = v_PIDB(v_Idx_PID);
m_Aso(:,2) = v_PIDE(v_Idx_PID);

v_Idx_Aso(v_Idx_Aso==0)=[];

m_Aso(:,3) = v_HFAB(v_Idx_Aso);
m_Aso(:,4) = v_HFAE(v_Idx_Aso);

% Establecer una referencia para alinear

str_Path = './Data/';
str_Slice = stru_MergData(xx).Slice;
load(strcat(str_Path,str_Slice,'.mat'));
% 
% N      = 70;   % Order
% Fstop1 = 180;  % First Stopband Frequency
% Fstop2 = 550;  % Second Stopband Frequency
% Astop  = 80;   % Stopband Attenuation (dB)
% 
% h  = fdesign.bandpass('N,Fst1,Fst2,Ast', N, Fstop1, Fstop2, Astop, s_SampRate);
% Hd = design(h, 'cheby2');
% 
% v_FilHFA = filter(Hd,v_RawData);
% v_FilHFA = flip(filter(Hd, flip(v_FilHFA)));

%%
s_Win = 4000;

% m_Aso(end,:)=[];
% m_Aso(486,:)=[];
% m_Aso(630,:)=[];
% m_Aso(635,:)=[];

m_Plot = [];
for i=1:size(m_Aso,1)

    %s_Ref = floor((m_Aso(i,1) + m_Aso(i,2))/2);
    s_Ref = m_Aso(i,1);
    v_Win = s_Ref-s_Win:s_Ref+s_Win;
%     v_Plot = v_FilData(v_Win);
    v_Seg_PID = zeros(1,numel(v_Win));
    v_Seg_HFA = zeros(1,numel(v_Win));

    v_HFA_TS = [m_Aso(i,3),m_Aso(i,4)]-(s_Ref-s_Win);
    v_PID_TS = [m_Aso(i,1),m_Aso(i,2)]-(s_Ref-s_Win);

    v_Seg_PID(v_PID_TS(1):v_PID_TS(2)) = 1;
    v_Seg_HFA(v_HFA_TS(1):v_HFA_TS(2)) = 0.5;

    m_Plot_PID(i,:) = v_Seg_PID;
    m_Plot_HFA(i,:) = v_Seg_HFA;
% 
%     figure()
%     plot(v_Plot,'k','LineWidth',0.8)
%     hold on
%     %plot(v_Seg_HFA,'b')
% %   plot(abs(hilbert(v_Seg_HFA)),'r')
%     plot(v_PID_TS(1),v_Plot(v_PID_TS(1)),'.r','MarkerSize',15)
%     plot(v_PID_TS(2),v_Plot(v_PID_TS(2)),'.b','MarkerSize',15)
%     xline(3001,'m','LineWidth',0.8)

end

v_Search = m_Aso(:,1);
[~,s_L1]= min(abs((v_Search-s_SS)));
[~,s_L2]= min(abs((v_Search-s_TG)));
v_LiPlot = abs([s_L1,s_L2]-numel(v_Search));

v_Pos = [277.5	74	2007.5	1276.5];
%v_PosI = [289.5	229.5	691.5 1040];
f = figure('Position',v_Pos);
subplot(5,6,1:6)
plot(s_BU:s_SS,v_FilData(s_BU:s_SS),'k')
hold on
plot(s_SS:s_TG,v_FilData(s_SS:s_TG),'b')
plot(s_TG:s_SO,v_FilData(s_TG:s_SO),'r')
xline([s_SS,s_TG],'LineWidth',1,'Color','m')
title(str_Slice)

subplot(5,6,[7 8 13 14 19 20 25 26])
f_ImageMatrix(m_Plot_PID, 1:size(m_Plot_PID,2),flip(1:size(m_Plot_PID,1)), [],'hot',256);
hold on
yline(v_LiPlot,'LineWidth',1,'Color','m')
title('PID duration')

subplot(5,6,[9 10 15 16 21 22 27 28])
f_ImageMatrix(m_Plot_HFA, 1:size(m_Plot_HFA,2),flip(1:size(m_Plot_HFA,1)), [],'hot',256);
yline(v_LiPlot,'LineWidth',1,'Color','m')
title('HFA duration')

subplot(5,6,[11 12 17 18 23 24 29 30])
f_ImageMatrix(abs(m_Plot_PID-m_Plot_HFA), 1:size(m_Plot_HFA,2),flip(1:size(m_Plot_HFA,1)), [],'hot',256);
yline(v_LiPlot,'LineWidth',1,'Color','m')
title('PID-HFA duration')

% saveas (f,strcat(str_Slice,'.png'))

load('Phase_PIDHFA_ref_mid.mat','stru_PID_HFA_Phase')
stru_PID_HFA_Phase(xx).m_PID = m_Plot_PID;
stru_PID_HFA_Phase(xx).m_HFA = m_Plot_HFA;
save('Phase_PIDHFA_ref_mid.mat','stru_PID_HFA_Phase')

%% Plot merging all
% clear; close all; clc
load('Phase_PIDHFA.mat','stru_PID_HFA_Phase')

v_SlicesP = [1:25];
%v_SlicesP = [4,19,20,18,9,11,1,12,5,13];
%v_SlicesP = [4,20,18,11,5,13]; 
%v_SlicesP = [18];
m_PID_BIG = [];
m_HFA_BIG = [];

for i=1:numel(v_SlicesP)
    s_Slice = v_SlicesP(i);
    m_PID_BIG = [m_PID_BIG;stru_PID_HFA_Phase(s_Slice).m_PID];
    m_HFA_BIG = [m_HFA_BIG;stru_PID_HFA_Phase(s_Slice).m_HFA];
end

v_2Sort = sum(m_PID_BIG,2);
[~,v_IndSort] = sort(v_2Sort);

m_PID_BIG = m_PID_BIG(v_IndSort,:);
m_HFA_BIG = m_HFA_BIG(v_IndSort,:);

subplot(1,3,1)
f_ImageMatrix(m_PID_BIG, 1:size(m_PID_BIG,2),flip(1:size(m_PID_BIG,1)), [],'hot',256);
title('PID duration')
subplot(1,3,2)
f_ImageMatrix(m_HFA_BIG, 1:size(m_HFA_BIG,2),flip(1:size(m_HFA_BIG,1)), [],'hot',256);
title('HFA duration')
subplot(1,3,3)
f_ImageMatrix(abs(m_PID_BIG-m_HFA_BIG), 1:size(m_HFA_BIG,2),flip(1:size(m_HFA_BIG,1)), [],'hot',256);
title('PID-HFA duration')
