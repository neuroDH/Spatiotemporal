%% Cleaning
clear; close all; clc

%% Loading

str_DataPath = 'C:\Users\david\Desktop\All_Data\Data\';
load('Names.mat')

%% Compute features

% Filter parameters
s_SampRate = 10000;
N      = 70;   % Order
Fstop1 = 100;  % First Stopband Frequency
Fstop2 = 600;  % Second Stopband Frequency
Astop  = 80;   % Stopband Attenuation (dB)

% Filter desing
h  = fdesign.bandpass('N,Fst1,Fst2,Ast', N, Fstop1, Fstop2, Astop, s_SampRate);
Hd = design(h, 'cheby2');

ii=25;

str_SliceName = strcat(stru_FolderNames(ii).Slice,'\');
load(strcat(str_DataPath,str_SliceName,'Peaks.mat'))

for jj=1:numel(stru_Pks)

    v_Pks = stru_Pks(jj).PksIndx;

    if isempty(v_Pks)
        stru_HFA(jj).PksIndx = [];
        continue
    else
        % Load and fil raw data
        load(strcat(str_DataPath,str_SliceName,'E',num2str(jj),'.mat'),...
            'v_RawData')
%         load(strcat(str_DataPath,str_SliceName,'E',num2str(jj),'.mat'),...
%             'v_FilData')

        v_FilHFA = filter(Hd,v_RawData);
        v_FilHFA = flip(filter(Hd, flip(v_FilHFA)));
        s_Tresh = mean(v_FilHFA)+4.5*std(v_FilHFA);

        v_TSHFA = [];
        cont = 1;

        for kk=1:numel(v_Pks)

            try
                v_Seg = v_FilHFA(v_Pks(kk)-1500:v_Pks(kk)+1500);
            catch
                continue
            end
            % v_Seg2 = v_FilData(v_Pks(kk)-1500:v_Pks(kk)+1500);
            % figure()
            % plot(v_Seg,'b')
            % hold on
            % plot(v_Seg2,'r')
            % yline(s_Tresh)
            % % 
            if max(abs(v_Seg))>=s_Tresh
                v_TSHFA(cont) = v_Pks(kk);
                cont=cont+1;
            end
        end       

    end

    stru_HFA(jj).PksIndx = v_TSHFA;

    disp(jj)

end

save(strcat(str_DataPath,str_SliceName,'PksHFA.mat'),'stru_HFA')

%% Verify HFA detection

str_SliceName = strcat(stru_FolderNames(ii).Slice,'\');
load(strcat(str_DataPath,str_SliceName,'Peaks.mat'))
load(strcat(str_DataPath,str_SliceName,'PksHFA.mat'))

jj=104;

v_Pks = stru_Pks(jj).PksIndx;
v_HFA = stru_HFA(jj).PksIndx;

% Load and fil raw data
load(strcat(str_DataPath,str_SliceName,'E',num2str(jj),'.mat'),...
    'v_FilData')
load(strcat(str_DataPath,str_SliceName,'E',num2str(jj),'.mat'),...
    'v_RawData')

v_FilHFA = filter(Hd,v_RawData);
v_FilHFA = flip(filter(Hd, flip(v_FilHFA)));
s_Tresh = mean(v_FilHFA)+4.5*std(v_FilHFA);

figure()
plot(v_FilData,'k')
hold on
plot(v_FilHFA,'r')
plot(v_Pks,v_FilData(v_Pks),'*r')
xline(v_HFA,'m')
yline(s_Tresh,'g')
yline(-s_Tresh,'g')

%%
for dh=1:120
    pks= stru_HFA(dh).PksIndx;

    if numel (pks)<=3
        stru_HFA(dh).PksIndx=[];
    else
        continue
    end
end
