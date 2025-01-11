function [m_Data,stru_Header,s_SampRate] = f_ReadRawData(str_FileName)

%% Get header
fileIDHeader = fopen(str_FileName,'r');
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

% Modify Chan 1 name

s_GodLen = numel(cll_Chan{6});
str_Temp = cll_Chan{1};
cll_Chan{1} = str_Temp(end-s_GodLen+1:end);

% Build structure variable with header info

stru_Header.s_ADCzero = s_ADCzero;
stru_Header.s_EI = s_EI;
stru_Header.s_NumElec = s_NumElec;
stru_Header.ChannOrder = cll_Chan;

%% Get data

fileID = fopen(str_FileName,'r');
disp('Reading data... this could take a while please wait')

str_TextRead = fgetl(fileID);
cont = 1;
while strcmp(str_TextRead,'EOH')~=1

    fseek(fileID,cont,'bof');
    str_TextRead = fgetl(fileID);
    cont = cont+1;
end
cont = cont+4;

fseek(fileID,cont,'bof');
v_Data = fread(fileID,'uint16')';
v_Data = s_EI*(v_Data-s_ADCzero);
fclose(fileID);

% Reshape data
m_Data = reshape(v_Data,[s_NumElec,numel(v_Data)/s_NumElec]);
disp('Done!')

end