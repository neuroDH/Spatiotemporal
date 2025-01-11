function f_Plot_All_Matrix_Big(str_SlicePath,v_Lims)

% Create figure

f= figure();
for i = 1:120
    a_plots(i)=subplot(10,12,i);
end
set(f,'Position',[1 41 1920 970])
set(f,'Color',[1,1,1])

% Resize and relocate plots
v_IniPos = [0.030,0.90,0.065,0.078];

v_Chang = 13:12:120;

for i = 1:120

    if i==1
        v_Pos = v_IniPos;
    end

    if sum(i== v_Chang)~=0
        v_Pos(2)= v_Pos(2)- 0.098;
        v_Pos(1)= v_IniPos(1);
    end
    set(a_plots(i),'xtick',[],'ytick',[])
    set(a_plots(i),'Position',v_Pos)
    set(a_plots(i),'Box','on')
    v_Pos(1)= v_Pos(1)+ 0.080;

end


% Space electrodes distribution (corresponding to v_ChannIndx for plot)

cll_ChannOrder = {
    'A1','B1','C1','D1','E1','F1','G1','H1','J1','K1','L1','M1',...
    'A2','B2','C2','D2','E2','F2','G2','H2','J2','K2','L2','M2',...
    'A3','B3','C3','D3','E3','F3','G3','H3','J3','K3','L3','M3',...
    'A4','B4','C4','D4','E4','F4','G4','H4','J4','K4','L4','M4',...
    'A5','B5','C5','D5','E5','F5','G5','H5','J5','K5','L5','M5',...
    'A6','B6','C6','D6','E6','F6','G6','H6','J6','K6','L6','M6',...
    'A7','B7','C7','D7','E7','F7','G7','H7','J7','K7','L7','M7',...
    'A8','B8','C8','D8','E8','F8','G8','H8','J8','K8','L8','M8',...
    'A9','B9','C9','D9','E9','F9','G9','H9','J9','K9','L9','M9',...
    'A10','B10','C10','D10','E10','F10','G10','H10','J10','K10','L10','M10'};

v_ChanIndx=[1:120];

cll_Order = {...                                                                  % From datasheet
    'F10','F9','F8','F7','F6','E10','E9','E8','E7','D10','D9','D8','C10','C9',...
    'B10','A10','B9','A9','C8','B8','A8','D7','C7','B7','A7','E6','D6','C6',...
    'B6','A6','A5','B5','C5','D5','E5','A4','B4','C4','D4','A3','B3','C3',...
    'A2','B2','A1','B1','C2','C1','D3','D2','D1','E4','E3','E2','E1','F5',...
    'F4','F3','F2','F1','G1','G2','G3','G4','G5','H1','H2','H3','H4','J1',...
    'J2','J3','K1','K2','L1','M1','L2','M2','K3','L3','M3','J4','K4','L4',...
    'M4','H5','J5','K5','L5','M5','M6','L6','K6','J6','H6','M7','L7','K7',...
    'J7','M8','L8','K8','M9','L9','M10','L10','K9','K10','J8','J9','J10',...
    'H7','H8','H9','H10','G6','G7','G8','G9','G10'};


load(strcat(str_SlicePath,'\Header.mat'),'stru_Header');
cll_Corres = stru_Header.ChannOrder;

% Title

annotation(f, 'textbox', [0,0.809,0.2,0.2], 'String',...
    str_SlicePath(end-7:end),...
    'FitBoxToText','on',...
    'EdgeColor','k',...
    'LineStyle','none',...
    'FontSize',16,...
    'FontWeight','bold');

% PLot early

for i=1:120

    str_TarEle = cll_Corres{i};
    str_TarEle = str_TarEle(4:end);
    str_TextCmp = cll_Order{str2num(str_TarEle)};
    cll_FindElec = strcmp(cll_ChannOrder,str_TextCmp);
    s_IndexCll = find(cll_FindElec);
    s_IndexPlot = v_ChanIndx(s_IndexCll);

    str_DataPath = strcat(str_SlicePath,'/E',num2str(i),'.mat');
    load(str_DataPath,'v_FilData');
    str_PksPath = strcat(str_SlicePath,'\Peaks.mat');
    load(str_PksPath,'stru_Pks')
    
    v_Data = v_FilData(1:10:end);
    v_Pks = floor((stru_Pks(i).PksIndx)./10);
    v_Aux = 1:numel(v_Data);

    plot(a_plots(s_IndexPlot),v_Aux,v_Data,v_Pks,v_Data(v_Pks),'*r');
    set(a_plots(s_IndexPlot),'YLim',v_Lims)
    set(a_plots(s_IndexPlot),'NextPlot','add')
    set(a_plots(s_IndexPlot),'xtick',[],'ytick',[])
  
    v_Pos = a_plots(s_IndexPlot).Position;

    annotation('textbox', [v_Pos(1),v_Pos(2)+0.06,0.01,0.01], 'String',...
        num2str(i),...
        'FitBoxToText','on',...
        'LineStyle','none');

end

end
