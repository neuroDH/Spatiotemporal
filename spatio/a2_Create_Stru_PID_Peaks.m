%% Cleaning
clear; close all; clc

%% Join peaks
str_sliceName = 'Peaks';
stru_Pks = [];

for i=1:120

    str_Name = strcat('E',num2str(i),'_Pks.mat');
    load(str_Name)
    stru_Pks(i).PksIndx=v_Indx;

end

str_name2save = strcat('./out_Data/',str_sliceName,'.mat');

save(str_name2save,'stru_Pks')