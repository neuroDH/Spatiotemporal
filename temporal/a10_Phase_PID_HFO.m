%% Cleaning

clear; close all; clc;

%% loading

load ('HFO_BST.mat')
addpath('./functions')

%%

xx = 10;
s_SampRate = 10000;

s_BU = stru_MergData(xx).BU;
s_SS = stru_MergData(xx).SS;
s_TG = stru_MergData(xx).TG;
s_SO = stru_MergData(xx).SO;

% Extraer PID asociadas con una HFA guardar estas PID y sus respectivas HFAs en una sola matriz

v_PIDB = stru_MergData(xx).PID_B;
v_PIDE = stru_MergData(xx).PID_E;
v_HFOB = stru_MergData(xx).HFO_B;
v_HFOE = stru_MergData(xx).HFO_E;

[v_Idx_PID,v_Idx_PID_No,stru_Idx_Aso] = f_Asocia_PID_HFO(v_PIDB,v_PIDE,v_HFOB,v_HFOE);

m_Aso(:,1) = v_PIDB(v_Idx_PID);
m_Aso(:,2) = v_PIDE(v_Idx_PID);

cont = 0;

stru_Idx_Aso2 = [];
for x = 1:numel(stru_Idx_Aso)
    s_Val = stru_Idx_Aso(x).IndxHFO;
    if isempty(s_Val)
        continue
    else
        cont = cont+1;
        stru_Idx_Aso2(cont).IndxHFO = s_Val ;
    end
end

m_Aso_R = [];

for x = 1:numel(stru_Idx_Aso2)

    v_Val = stru_Idx_Aso2(x).IndxHFO;

    for y=1:numel(v_Val)

        m_Aso_R(v_Val(y),1) = m_Aso(x,1);
        m_Aso_R(v_Val(y),2) = m_Aso(x,2);
        m_Aso_R(v_Val(y),3) = v_HFOB(v_Val(y));
        m_Aso_R(v_Val(y),4) = v_HFOE(v_Val(y));

    end

end

v_Aso_R_Del = m_Aso_R(:,1)==0;
m_Aso_R(v_Aso_R_Del,:)=[];
% Establecer una referencia para alinear

str_Path = './Data_HFO/';
str_Slice = stru_MergData(xx).Slice;
load(strcat(str_Path,str_Slice,'.mat'));

%%
s_Win = 3000;

%m_Aso_R(69,:)=[];

% m_Aso(383,:)=[];

m_Plot = [];
for i=1:size(m_Aso_R,1)

    %s_Ref = floor((m_Aso_R(i,1) + m_Aso_R(i,2))/2);
    s_Ref = m_Aso_R(i,1);
    v_Win = s_Ref-s_Win:s_Ref+s_Win+1500;
    v_Seg_PID = zeros(1,numel(v_Win));
    v_Seg_HFO = zeros(1,numel(v_Win));

    v_HFO_TS = [m_Aso_R(i,3),m_Aso_R(i,4)]-(s_Ref-s_Win);
    v_PID_TS = [m_Aso_R(i,1),m_Aso_R(i,2)]-(s_Ref-s_Win);

    v_Seg_PID(v_PID_TS(1):v_PID_TS(2)) = 1;
    v_Seg_HFO(v_HFO_TS(1):v_HFO_TS(2)) = 0.5;

    m_Plot_PID(i,:) = v_Seg_PID;
    m_Plot_HFO(i,:) = v_Seg_HFO;

%     figure()
%     plot(v_Seg,'k')
%     hold on
%     plot(v_Seg_HFA,'b')
%     plot(abs(hilbert(v_Seg_HFA)),'r')
%     xline(v_PID_TS,'m')

end

% Ordenar de menor a mayor duracion?

[~,b] = sort(sum(m_Plot_PID,2));

m_Plot_PID = m_Plot_PID(b,:);
m_Plot_HFO = m_Plot_HFO(b,:);

v_Search = m_Aso_R(:,1);
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
f_ImageMatrix(m_Plot_HFO, 1:size(m_Plot_HFO,2),flip(1:size(m_Plot_HFO,1)), [],'hot',256);
yline(v_LiPlot,'LineWidth',1,'Color','m')
title('HFO duration')

subplot(5,6,[11 12 17 18 23 24 29 30])
f_ImageMatrix(abs(m_Plot_PID-m_Plot_HFO), 1:size(m_Plot_HFO,2),flip(1:size(m_Plot_HFO,1)), [],'hot',256);
yline(v_LiPlot,'LineWidth',1,'Color','m')
title('PID-HFO duration')

%% saveas (f,strcat(str_Slice,'.png'))

load('Phase_PIDHFO.mat','stru_PID_HFO_Phase')
stru_PID_HFO_Phase(xx).m_PID = m_Plot_PID;
stru_PID_HFO_Phase(xx).m_HFO = m_Plot_HFO;
save('Phase_PIDHFO.mat','stru_PID_HFO_Phase')

%% Plot merging all
clear; close all; clc
load('Phase_PIDHFO.mat','stru_PID_HFO_Phase')

v_SlicesP = [1:15];
%v_SlicesP = [10,14,4,2,6,8];
%v_SlicesP = [10,14,4,2];
%v_SlicesP = [4,20,18,11,5,13];
%v_SlicesP = [19,20,18];
m_PID_BIG = [];
m_HFO_BIG = [];

for i=1:numel(v_SlicesP)
    s_Slice = v_SlicesP(i);
    m_PID_BIG = [m_PID_BIG;stru_PID_HFO_Phase(s_Slice).m_PID];
    m_HFO_BIG = [m_HFO_BIG;stru_PID_HFO_Phase(s_Slice).m_HFO];
end

v_2Sort = sum(m_PID_BIG,2);
[~,v_IndSort] = sort(v_2Sort);

m_PID_BIG = m_PID_BIG(v_IndSort,:);
m_HFO_BIG = m_HFO_BIG(v_IndSort,:);

a = subplot(1,3,1);
f_ImageMatrix(m_PID_BIG, 1:size(m_PID_BIG,2),flip(1:size(m_PID_BIG,1)), [],'hot',256);
title('PID duration')
b = subplot(1,3,2);
f_ImageMatrix(m_HFO_BIG, 1:size(m_HFO_BIG,2),flip(1:size(m_HFO_BIG,1)), [],'hot',256);
title('HFO duration')
c = subplot(1,3,3);
f_ImageMatrix(abs(m_PID_BIG-m_HFO_BIG), 1:size(m_HFO_BIG,2),flip(1:size(m_HFO_BIG,1)), [],'hot',256);
title('PID-HFO duration')
linkaxes([a,b,c],'x')
%xlim([2000,7100])