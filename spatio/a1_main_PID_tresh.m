function a1_main_PID_tresh(conFiles)

%% Create figure

fig2plot = figure();
set (fig2plot,'Position',[625.7	249	1804.8 726])

%% Create panels

panelPlot = uipanel('Parent',fig2plot,...
    'BackgroundColor','white',...
    'Position',[0.02, 0.16, 0.962, 0.82]);

panelButtons = uipanel('Parent',fig2plot,...
    'Position',[0.02, 0.01, 0.962, 0.15]);

%% Create axis

AxisPlot = axes(panelPlot);

%% Create buttons and boxes

but_SelFolder = uicontrol(panelButtons,...
    'Style','push',...
    'String','Select folder',...
    'FontSize',11,...
    'Position',[18 40 110 36],...
    'Callback',@f_SelectFolder);

lab_Time1 = uicontrol(panelButtons,...
    'Style','text',...
    'String','Par 1',...
    'FontSize',11,...
    'Position',[135 40 70 36]);

box_Time1 = uicontrol(panelButtons,...
    'Style','edit',...
    'BackgroundColor','w',...
    'String','300',...
    'FontSize',11,...
    'Position',[215 60 70 36]);

box_Tresh1 = uicontrol(panelButtons,...
    'Style','edit',...
    'BackgroundColor','w',...
    'String','10',...
    'FontSize',11,...
    'Position',[215 15 70 36]);

lab_Time2 = uicontrol(panelButtons,...
    'Style','text',...
    'String','Par 2',...
    'FontSize',11,...
    'Position',[295 40 70 36]);

box_Time2 = uicontrol(panelButtons,...
    'Style','edit',...
    'BackgroundColor','w',...
    'String','600',...
    'FontSize',11,...
    'Position',[375 60 70 36]);

box_Tresh2 = uicontrol(panelButtons,...
    'Style','edit',...
    'BackgroundColor','w',...
    'String','10',...
    'FontSize',11,...
    'Position',[375 15 70 36]);

lab_Time3 = uicontrol(panelButtons,...
    'Style','text',...
    'String','Par 3',...
    'FontSize',11,...
    'Position',[455 40 70 36]);

box_Time3 = uicontrol(panelButtons,...
    'Style','edit',...
    'BackgroundColor','w',...
    'String','1000',...
    'FontSize',11,...
    'Position',[535 60 70 36]);

box_Tresh3 = uicontrol(panelButtons,...
    'Style','edit',...
    'BackgroundColor','w',...
    'String','10',...
    'FontSize',11,...
    'Position',[535 15 70 36]);

lab_Time4 = uicontrol(panelButtons,...
    'Style','text',...
    'String','Par 4',...
    'FontSize',11,...
    'Position',[615 40 70 36]);

box_Time4 = uicontrol(panelButtons,...
    'Style','edit',...
    'BackgroundColor','w',...
    'String','1500',...
    'FontSize',11,...
    'Position',[695 60 70 36]);

box_Tresh4 = uicontrol(panelButtons,...
    'Style','edit',...
    'BackgroundColor','w',...
    'String','10',...
    'FontSize',11,...
    'Position',[695 15 70 36]);

lab_MPD = uicontrol(panelButtons,...
    'Style','text',...
    'String','min PkD',...
    'FontSize',11,...
    'Position',[775 30 70 36]);

box_MPD = uicontrol(panelButtons,...
    'Style','edit',...
    'BackgroundColor','w',...
    'String','4000',...
    'FontSize',11,...
    'Position',[855 40 70 36]);

but_Updatechart = uicontrol(panelButtons,...
    'Style','push',...
    'String','Update',...
    'FontSize',11,...
    'Position',[950+135 40 110 36],...
    'Callback',@f_UpdateChart);

but_SaveandNext = uicontrol(panelButtons,...
    'Style','push',...
    'String','Save & Next',...
    'FontSize',11,...
    'Position',[1080+135 40 110 36],...
    'Callback',@f_SaveandNext);

but_SkipandNext = uicontrol(panelButtons,...
    'Style','push',...
    'String','Skip & Next',...
    'FontSize',11,...
    'Position',[1210+135 40 110 36],...
    'Callback',@f_SkipandNext);

but_Restore = uicontrol(panelButtons,...
    'Style','push',...
    'String','Res view',...
    'FontSize',11,...
    'Position',[1340+135 40 110 36],...
    'Callback',@f_RestoreView);

but_Exit = uicontrol(panelButtons,...
    'Style','push',...
    'String','Exit',...
    'FontSize',11,...
    'Position',[1340+260 40 110 36],...
    'Callback',@f_Exit);

but_RemoveCurpeak = uicontrol(panelButtons,...
    'Style','push',...
    'String','Remove Pk',...
    'FontSize',11,...
    'Position',[950 40 110 36],...
    'Callback',@f_RemoveCurpeak);

but_CheckInv = uicontrol(panelButtons,...
    'Style','checkbox',...
    'Position',[995+135 25 15 10]);


%% Initial variables

str_NumFiles = 0;
%conFiles = 0;
selpath = [];
s_SampRate = 0;
v_Data = 0;
v_RawData = 0;
v_Indx = 0;
h=[];
AxisPlot = [];
s_OnlyOne = 0;
v_xLims = [];
v_yLims = [];
s_InfXIni = 0;
s_SupXIni = 0;
s_InfYIni = 0;
s_SupYIni = 0;
s_InfX = 0;
s_SupX = 0;
s_InfY = 0;
s_SupY = 0;
Nfir = 70;
Fst = 50;


%% Functions

    function f_Exit(~,~)
        close all
    end

    function f_SelectFolder(~,~)
        selpath = uigetdir;
        str_NumFiles = numel(dir(selpath))-3;
        f_LoadData();
        f_UpdateChart();

    end

    function f_LoadData(~,~)
        
        conFiles = conFiles+1;
        str_Name2Load = strcat(selpath,'\E',num2str(conFiles),'.mat');
        tempstru = load(str_Name2Load);
        s_SampRate = tempstru.s_SampRate;
        
        %v_Data = tempstru.v_FilData;

        v_RawData = tempstru.v_RawData;
        
        firf = designfilt('lowpassfir','FilterOrder',Nfir, ...
            'CutoffFrequency',Fst,'SampleRate',s_SampRate);

        v_Data = filter(firf,v_RawData);
        s_delay = mean(grpdelay(firf));
        v_Data(1:s_delay)=[];
        clear tempstru
        
    end

    function f_UpdateChart(~,~)

        % Get user values

        s_Time1 = str2double(box_Time1.String);
        s_Tresh1 = str2double(box_Tresh1.String);
        s_Time2 = str2double(box_Time2.String);
        s_Tresh2 = str2double(box_Tresh2.String);
        s_Time3 = str2double(box_Time3.String);
        s_Tresh3 = str2double(box_Tresh3.String);
        s_Time4 = str2double(box_Time4.String);
        s_Tresh4 = str2double(box_Tresh4.String);

        s_MPD = str2double(box_MPD.String);
        s_CheckVal = get(but_CheckInv,'value');

         v_IndxPos = [];

        if s_CheckVal == 1
            v_DataPks = v_Data;
            v_DataPks(v_DataPks>0) = 0;
            v_DataPks = abs(v_DataPks);
%             v_IndxPos = 1;
        else
            v_DataPks = v_Data;
        end

%         v_Tresh_All = [s_Tresh1,s_Tresh2,s_Tresh3,s_Tresh4];
%         s_MinTresh = min(v_Tresh_All);


        % Det Pks
        [~,v_Indx] = findpeaks(v_DataPks,'MinPeakHeight',2,...
            'MinPeakDistance',s_MPD);

        % Clean according to tresh

        s_Samp1 = floor(s_Time1*s_SampRate);
        s_Samp2 = floor(s_Time2*s_SampRate);
        s_Samp3 = floor(s_Time3*s_SampRate);
        s_Samp4 = floor(s_Time4*s_SampRate);

        v_Del = [];
        cont = 1;

        for dh = 1:numel(v_Indx)

            if v_Indx(dh)> 0 && v_Indx(dh)< s_Samp1 && v_DataPks(v_Indx(dh))< s_Tresh1
                v_Del(cont) = dh;
            elseif v_Indx(dh)> s_Samp1 && v_Indx(dh)< s_Samp2 && v_DataPks(v_Indx(dh))<s_Tresh2
                v_Del(cont) = dh;
            elseif v_Indx(dh)> s_Samp2 && v_Indx(dh)< s_Samp3 && v_DataPks(v_Indx(dh))<s_Tresh3
                v_Del(cont) = dh;
            elseif v_Indx(dh)> s_Samp3 && v_Indx(dh)< s_Samp4 && v_DataPks(v_Indx(dh))<s_Tresh4
                v_Del(cont) = dh;
            else
                cont = cont -1;
            end

            cont = cont + 1;

        end

        v_Indx(v_Del)=[];


%         if v_IndxPos==1
% 
%             v_Eval = v_Data(v_Indx);
%             v_Del2 = v_Eval>0;
%             v_Indx(v_Del2)=[];
%              
%         end


         if s_OnlyOne == 0
             f_BasicPlot()
             f_GetLim()
             s_OnlyOne = 1;
         else
             f_GetLim()
             f_BasicPlot()
             f_KeepLim()
        end
        

    end

    function f_SaveandNext(~,~)

        if conFiles > str_NumFiles
            str_name2save = strcat('E',num2str(conFiles),'_Pks.mat');
            save(str_name2save,'v_Indx')
            close all
        else

            str_name2save = strcat('E',num2str(conFiles),'_Pks.mat');
            save(str_name2save,'v_Indx')
            s_OnlyOne = 0;
            f_LoadData()
            f_UpdateChart()            
        end
        
    end

    function f_SkipandNext(~,~)

        if conFiles > str_NumFiles
            v_Indx = [];
            str_name2save = strcat('E',num2str(conFiles),'_Pks.mat');
            save(str_name2save,'v_Indx')
            close all
        else

            v_Indx = [];
            str_name2save = strcat('E',num2str(conFiles),'_Pks.mat');
            save(str_name2save,'v_Indx')
            s_OnlyOne = 0;
            f_LoadData()
            f_UpdateChart()
            
        end
    end

    function f_RemoveCurpeak(~,~)

        s = getCursorInfo(h);
        s_IndxRev =s.DataIndex;
        v_Indx(s_IndxRev)=[];
        f_UpdatePlotDelPk ()

    end

    function f_UpdatePlotDelPk (~,~)

        f_GetLim()
        f_BasicPlot()
        h=datacursormode;
        f_KeepLim()


    end

    function f_KeepLim(~,~)

        AxisPlot.XAxis.Limits = [s_InfX,s_SupX];
        AxisPlot.YAxis.Limits = [s_InfY,s_SupY];
    end

    function f_GetLim(~,~)

        v_xLims = AxisPlot.XAxis.Limits;
        v_yLims = AxisPlot.YAxis.Limits;

        if s_OnlyOne == 0

            s_InfXIni = v_xLims(1);
            s_SupXIni = v_xLims(2);
            s_InfYIni = v_yLims(1);
            s_SupYIni = v_yLims(2);

        else
            s_InfX = v_xLims(1);
            s_SupX = v_xLims(2);
            s_InfY = v_yLims(1);
            s_SupY = v_yLims(2);
        end

    end

    function f_RestoreView(~,~)

        AxisPlot.XAxis.Limits = [s_InfXIni,s_SupXIni];
        AxisPlot.YAxis.Limits = [s_InfYIni,s_SupYIni];

    end

    function f_BasicPlot(~,~)

        v_Time = (0:numel(v_Data)-1)./s_SampRate;
        plot(v_Time,v_Data)
        hold on
        plot(v_Time(v_Indx),v_Data(v_Indx),'r*')
        xlabel('time (s)')
        ylabel('filtered amplitude (uV)')
        title(conFiles)
        hold off
%         b = subplot(2,1,2);
%         plot(v_Time2,v_RawData)
%         xlabel('time (s)')
%         ylabel('raw amplitude (uV)')
%         title(num2str(numel(v_Indx)))
%         linkaxes([a,b],'x')
        h=datacursormode;
        AxisPlot = gca;

    end


end
