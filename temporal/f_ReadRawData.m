function [v_Data,stru_Header,s_NewSamRate] = f_ReadRawData(str_FileNameDataRaw,s_NewSamRate)

% Get header
fileIDHeader = fopen(str_FileNameDataRaw,'r');
tline = fgetl(fileIDHeader);
disp('Reading header...')

while 1

    if contains(tline,'Sample')
        s_SampRate = str2double(tline(15:end));
    elseif contains(tline,'ADC')
        s_ADCzero = str2double(tline(11:end));
    elseif contains(tline,'V/AD')
        s_EI = str2double(tline(5:strfind(tline,'V/AD')-2));
    elseif contains(tline,'Streams')
        str_Chn = tline;
        [cll_Chan,~] = strsplit(str_Chn,';');
        s_NumElec = numel(cll_Chan);        
    elseif strcmp(tline,'EOH') == 1
        break
    end

    tline = fgetl(fileIDHeader);
end

fclose(fileIDHeader);
disp('Done!')

% Build structure variable with header info

stru_Header.s_ADCzero = s_ADCzero;
stru_Header.s_EI = s_EI;
stru_Header.s_NumElec = s_NumElec;
stru_Header.ChannOrder = cll_Chan;

fprintf('\n');      

%% Get data

disp('Reading data...')

fileID = fopen(str_FileNameDataRaw,'r');

str_TextRead = fgetl(fileID);
cont = 1;
while strcmp(str_TextRead,'EOH')~=1

    fseek(fileID,cont,'bof');
    str_TextRead = fgetl(fileID);
    cont = cont+1;
end
cont = cont+4;

fseek(fileID,cont,'bof');
v_Data = fread(fileID,'uint16=>uint16')';
fclose(fileID);

v_Data = double(v_Data);
v_Data = s_EI*(v_Data-s_ADCzero);

%% Subsampling

s_Factor = s_SampRate/s_NewSamRate;
v_Data = v_Data(1:s_Factor:end);

disp('Done!')
fprintf('\n');

end