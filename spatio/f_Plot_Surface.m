function f_Plot_Surface(v_Ele_Early,v_Ele_Late,v_Ele_Active,str_pathSlice)

str_Header = strcat(str_pathSlice,'Header.mat');
load(str_Header,'stru_Header')
cll_Chan = stru_Header.ChannOrder;
str_Chan = cll_Chan{1};
str_Chan = str_Chan(4:end);

if isnan(str2double(str_Chan))
    str_Matrix = 'Small';
else
    str_Matrix = 'Big';
end

if strcmp(str_Matrix,'Small')

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

    % Remove corners plot (small matrix shape)
    v_All = 1:12*12;
    v_Remove = ~ismember(v_All,v_ChanIndx);
    v_Ax2Remove = v_All(v_Remove);

    for i=1:numel(v_Ax2Remove)

        set(a_plots(v_Ax2Remove(i)),'xtick',[],'ytick',[])
        set(a_plots(v_Ax2Remove(i)),'XColor', 'none','YColor','none')
        set(a_plots(v_Ax2Remove(i)),'Box','off')

    end

    %% Load correspondance

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
 
    % str_Header = strcat(str_pathSlice,'\Header.mat');
    % load(str_Header,'stru_Header')
    cll_Corres = stru_Header.ChannOrder;

    % Title

    annotation(f, 'textbox', [0.485,0.8,0.2,0.2], 'String',...
        str_pathSlice(end-8:end-1),...
        'FitBoxToText','on',...
        'EdgeColor','w');

    % Plot active

    for i=1:numel(v_Ele_Active)

        s_ElecPlot = v_Ele_Active(i);
        str_TarEle = cll_Corres{s_ElecPlot};
        str_TarEle = str_TarEle(4:end);
        cll_FindElec = strcmp(cll_ChannOrder,str_TarEle);
        s_IndexCll = find(cll_FindElec);
        s_IndexPlot = v_ChanIndx(s_IndexCll);

        set(a_plots(s_IndexPlot),'Color',[1.0000    0.9725    0.8627])

    end

    % Plot early

    for i=1:numel(v_Ele_Early)

        s_ElecPlot = v_Ele_Early(i);
        str_TarEle = cll_Corres{s_ElecPlot};
        str_TarEle = str_TarEle(4:end);
        cll_FindElec = strcmp(cll_ChannOrder,str_TarEle);
        s_IndexCll = find(cll_FindElec);
        s_IndexPlot = v_ChanIndx(s_IndexCll);

        set(a_plots(s_IndexPlot),'Color','r')

    end

    % Plot late

    for i=1:numel(v_Ele_Late)

        s_ElecPlot = v_Ele_Late(i);
        str_TarEle = cll_Corres{s_ElecPlot};
        str_TarEle = str_TarEle(4:end);
        cll_FindElec = strcmp(cll_ChannOrder,str_TarEle);
        s_IndexCll = find(cll_FindElec);
        s_IndexPlot = v_ChanIndx(s_IndexCll);

        set(a_plots(s_IndexPlot),'Color','b')

    end

elseif strcmp(str_Matrix,'Big')

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


    % load(strcat(str_pathSlice,str_Slice,'\Header.mat'),'stru_Header')
    cll_Corres = stru_Header.ChannOrder;

    % Title

    annotation(f, 'textbox', [0.485,0.8,0.2,0.2], 'String',...
        str_pathSlice(end-8:end-1),...
        'FitBoxToText','on',...
        'EdgeColor','w');

    % Plot active

    for i=1:numel(v_Ele_Active)

        s_ElecPlot = v_Ele_Active(i);
        str_TarEle = cll_Corres{s_ElecPlot};
        str_TarEle = str_TarEle(4:end);
        str_TextCmp = cll_Order{str2num(str_TarEle)};
        cll_FindElec = strcmp(cll_ChannOrder,str_TextCmp);
        s_IndexCll = find(cll_FindElec);
        s_IndexPlot = v_ChanIndx(s_IndexCll);

        set(a_plots(s_IndexPlot),'Color',[1.0000    0.9725    0.8627])

    end

    % Plot early

    for i=1:numel(v_Ele_Early)

        s_ElecPlot = v_Ele_Early(i);
        str_TarEle = cll_Corres{s_ElecPlot};
        str_TarEle = str_TarEle(4:end);
        str_TextCmp = cll_Order{str2num(str_TarEle)};
        cll_FindElec = strcmp(cll_ChannOrder,str_TextCmp);
        s_IndexCll = find(cll_FindElec);
        s_IndexPlot = v_ChanIndx(s_IndexCll);

        set(a_plots(s_IndexPlot),'Color','r')

    end

    % PLot late

    for i=1:numel(v_Ele_Late)

        s_ElecPlot = v_Ele_Late(i);
        str_TarEle = cll_Corres{s_ElecPlot};
        str_TarEle = str_TarEle(4:end);
        str_TextCmp = cll_Order{str2num(str_TarEle)};
        cll_FindElec = strcmp(cll_ChannOrder,str_TextCmp);
        s_IndexCll = find(cll_FindElec);
        s_IndexPlot = v_ChanIndx(s_IndexCll);

        set(a_plots(s_IndexPlot),'Color','b')

    end

     
end


end