function f_Plot_All_Matrix_Small(str_SlicePath,v_Lims)

%% Create figure

f= figure();
for i = 1:144
    a_plots(i)=subplot(12,12,i);
end
set(f,'Position',[1 41 1920 970])
set(f,'Color',[1,1,1])

% Resize and relocate plots
v_IniPos = [0.0850,0.9050,0.060,0.068];

v_Chang = 13:12:144;

for i = 1:144

    if i==1
        v_Pos = v_IniPos;
    end

    if sum(i== v_Chang)~=0
        v_Pos(2)= v_Pos(2)- 0.08;
        v_Pos(1)= v_IniPos(1);
    end
    set(a_plots(i),'xtick',[],'ytick',[])
    set(a_plots(i),'Position',v_Pos)
    set(a_plots(i),'Box','on')
    v_Pos(1)= v_Pos(1)+ 0.070;

end

v_ChanIndx=[4,5,6,7,8,9,...
    15,16,17,18,19,20,21,22,...
    26,27,28,29,30,31,32,33,34,35,...
    37,38,39,40,41,42,43,44,45,46,47,48,...
    49,50,51,52,53,54,55,56,57,58,59,60,...
    61,62,63,64,65,66,67,68,69,70,71,72,...
    73,74,75,76,77,78,79,80,81,82,83,84,...
    85,86,87,88,89,90,91,92,93,94,95,96,...
    97,98,99,100,101,102,103,104,105,106,107,108,...
    110,111,112,113,114,115,116,117,118,119,...
    123,124,125,126,127,128,129,130,...
    136,137,138,139,140,141];

% Remove corners (small matrix shape)
v_All = 1:12*12;
v_Remove = ~ismember(v_All,v_ChanIndx);
v_Ax2Remove = v_All(v_Remove);

for i=1:numel(v_Ax2Remove)

    set(a_plots(v_Ax2Remove(i)),'xtick',[],'ytick',[])
    set(a_plots(v_Ax2Remove(i)),'XColor', 'none','YColor','none')
    set(a_plots(v_Ax2Remove(i)),'Box','off')

end

%% Load correspondance location

% Space electrodes distribution (corresponding to v_ChannIndx for plot)

cll_ChannOrder = {'D1','E1','F1','G1','H1','J1',...
    'C2','D2','E2','F2','G2','H2','J2','K2',...
    'B3','C3','D3','E3','F3','G3','H3','J3','K3','L3',...
    'A4','B4','C4','D4','E4','F4','G4','H4','J4','K4','L4','M4',...
    'A5','B5','C5','D5','E5','F5','G5','H5','J5','K5','L5','M5',...
    'A6','B6','C6','D6','E6','F6','G6','H6','J6','K6','L6','M6',...
    'A7','B7','C7','D7','E7','F7','G7','H7','J7','K7','L7','M7',...
    'A8','B8','C8','D8','E8','F8','G8','H8','J8','K8','L8','M8',...
    'A9','B9','C9','D9','E9','F9','G9','H9','J9','K9','L9','M9',...
    'B10','C10','D10','E10','F10','G10','H10','J10','K10','L10',...
    'C11','D11','E11','F11','G11','H11','J11','K11',...
    'D12','E12','F12','G12','H12','J12'};

load(strcat(str_SlicePath,'\Header.mat'),'stru_Header');
cll_Corres = stru_Header.ChannOrder;

% Title

annotation(f, 'textbox', [0.100,0.7,0.2,0.2], 'String',...
    str_SlicePath(end-7:end),...
    'FitBoxToText','on',...
    'EdgeColor','k',...
    'LineStyle','none',...
    'FontSize',16,...
    'FontWeight','bold');

% Plot
for i = 1:numel(cll_Corres)

    str_DataPath = strcat(str_SlicePath,'/E',num2str(i),'.mat');
    str_PksPath = strcat(str_SlicePath,'\Peaks.mat');
    load(str_DataPath,'v_FilData');
    load(str_PksPath,'stru_Pks')
    v_Data = v_FilData(1:10:end);
    v_Pks = floor((stru_Pks(i).PksIndx)./10);

    str_ChanName = cll_Corres{i};
    str_ChanName = str_ChanName(4:end);
    [~,s_IndxCell] = find(strcmp(cll_ChannOrder,str_ChanName)==1);
    v_Aux = 1:numel(v_Data);

    s_CorresPlot = v_ChanIndx(s_IndxCell);

    plot(a_plots(s_CorresPlot),v_Aux,v_Data,v_Pks,v_Data(v_Pks),'*r');
    %v_Pks,v_Data(v_Pks),'*r'
    set(a_plots(s_CorresPlot),'YLim',v_Lims)
    set(a_plots(s_CorresPlot),'NextPlot','add')
    set(a_plots(s_CorresPlot),'xtick',[],'ytick',[])
    
    v_Pos = a_plots(s_CorresPlot).Position;

    annotation('textbox', [v_Pos(1),v_Pos(2)+0.06,0.01,0.01], 'String',...
        num2str(i),...
        'FitBoxToText','on',...
        'LineStyle','none');
end

end
