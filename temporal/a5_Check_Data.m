%% Cleaning
clear; close all; clc;

load('Time_Sta.mat','stru_TS')
str_Path = 'C:\Users\david.henao\Desktop\Quantifica_paper\1_Temporal_dynamic_HFA_HFO\finales\Check_Elec\';
%fileList = dir(fullfile(str_Path, '*.raw'));

for i = 1:25

    str_Slice = strcat(str_Path, stru_MergData(i).Slice,'.raw');
    [v_RawData,~,s_SampRate] = f_ReadRawData(str_Slice,10000);
    %v_Time = (0:numel(v_Data)-1)./s_SampRate;

    Nfir = 70;
    Fst = 50;
    firf = designfilt('lowpassfir','FilterOrder',Nfir, ...
        'CutoffFrequency',Fst,'SampleRate',s_SampRate);
    v_Data = filter(firf,v_Data);
    v_Data = flip(filter(firf, flip(v_Data)));

    figure()
    plot(v_Data,'b')
    hold on
    xline([stru_MergData(i).BU,stru_MergData(i).SS,stru_MergData(i).TG,stru_MergData(i).SO],'m',{'BU','SS','TG','So'});
    title(stru_MergData(i).Slice)
    xlim([stru_MergData(i).BU-500000,stru_MergData(i).SO+500000])

end

%% Transform 2 samples

clear; close all; clc;

load('PID_HFA.mat')
str_Path = './Data/';

for i = 1:numel(stru_MergData)

    str_Slice = stru_MergData(i).Slice;
    str_NameLoad = strcat(str_Path,str_Slice,'.mat'); 
    load(str_NameLoad,'v_FilData')

    v_Ini = stru_MergData(i).PID_B;
    v_Fin = stru_MergData(i).PID_E;

    v_Pks = [];
    for j=1:numel(v_Ini)
        v_Seg = v_FilData(v_Ini(j):v_Fin(j));
        [~,s_IndxMax] = max(v_Seg);
        v_Pks(j) = v_Ini(j)+s_IndxMax;
    end
   
    figure()
    plot(v_FilData,'b')
    hold on
    plot(v_Ini,v_FilData(v_Ini),'*r')
    plot(v_Fin,v_FilData(v_Fin),'*m')
    plot(v_Pks,v_FilData(v_Pks),'*k')
    try
        xline([stru_MergData(i).BU,stru_MergData(i).SS,stru_MergData(i).TG,stru_MergData(i).SO],'m',{'BU','SS','TG','So'});
    catch
        xline([stru_MergData(i).BU,stru_MergData(i).TG,stru_MergData(i).SO],'m',{'BU','TG','So'});
    end

    title(stru_MergData(i).Slice)
    xlim([stru_MergData(i).BU-500000,stru_MergData(i).SO+500000])

end

%% Transform 2 samples

clear; close all; clc;

load('HFO_BST.mat')
str_Path = './Check_Elec/';

for i = 1:numel(stru_MergData)

    str_Slice = strcat(stru_MergData(i).Slice,'.raw');
    str_Electrode = stru_MergData(i).Electrode;

    [v_RawData,~,s_SampRate] = f_ReadRawData(strcat(str_Path,str_Slice),10000);

    Nfir = 70;
    Fst = 50;
    firf = designfilt('lowpassfir','FilterOrder',Nfir, ...
        'CutoffFrequency',Fst,'SampleRate',s_SampRate);
    v_Data = filter(firf,v_RawData);
    v_FilData = flip(filter(firf, flip(v_Data)));

    s_Cut1 = stru_MergData.


end