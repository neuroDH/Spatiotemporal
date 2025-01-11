%% Cleaning
clear; close all; clc;

%% Load and plot

str_Path = 'C:\Users\david\Desktop\All_Data\Data\';
load('Names.mat')

for d = 1:numel(stru_FolderNames)
    str_Folder = stru_FolderNames(d).Slice;
    str_Electr = num2str(stru_FolderNames(d).Elec);

    str_CompPath = strcat(str_Path,str_Folder,'\E',str_Electr,'.mat');
    str_PksPath = strcat(str_Path,str_Folder,'\Peaks.mat');
    load(str_CompPath,'v_FilData')
    load(str_PksPath,'stru_Pks')

    v_Pks = stru_Pks(str2double(str_Electr)).PksIndx;

    figure()
    plot(v_FilData,'k')
    hold on
    plot(v_Pks,v_FilData(v_Pks),'*r')
    xline([stru_FolderNames(d).SS,stru_FolderNames(d).TG,stru_FolderNames(d).SO],'m')

end

 % figure()
 % plot(v_FilData,'k')
 % hold on
 % plot(v_Pks,v_FilData(v_Pks),'*r')
 % xline([11637301	15453601	15746801],'m')
 
 %% Plot Grid

 for x =1:25

     str_PlotPath = strcat(str_Path,stru_FolderNames(x).Slice);
     str_Headerpath = strcat(str_PlotPath,'\Header.mat');
     load(str_Headerpath)

     cll_Test= stru_Header(1).ChannOrder;
     str_Test = cll_Test{1};
     s_Test = str2double(str_Test(end-1:end));

     v_Lims = [-200,200];

     if isnan (s_Test)
         f_Plot_All_Matrix_Small(str_PlotPath,v_Lims)
     else
         f_Plot_All_Matrix_Big(str_PlotPath,v_Lims)
     end

     f=gcf;
     saveas(f,strcat(stru_FolderNames(x).Slice,'.png'))
     close (f)

 end


 %%

 x=25;
 str_PlotPath = strcat(str_Path,stru_FolderNames(x).Slice);
 str_Headerpath = strcat(str_PlotPath,'\Header.mat');
 load(str_Headerpath)

 cll_Test= stru_Header(1).ChannOrder;
 str_Test = cll_Test{1};
 s_Test = str2double(str_Test(end-1:end));

 v_Lims = [-100,500];

 if isnan (s_Test)
     f_Plot_All_Matrix_Small(str_PlotPath,v_Lims)
 else
     f_Plot_All_Matrix_Big(str_PlotPath,v_Lims)
 end

 f=gcf;
 saveas(f,strcat(stru_FolderNames(x).Slice,'.png'))
