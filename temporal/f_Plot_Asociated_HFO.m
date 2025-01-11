function [v_B_Bag, v_S_Bag,v_T_Bag, v_B_A_Bag,v_S_A_Bag,v_T_A_Bag,v_BarPlot,v_Erro,stru_Joint] = ...
    f_Plot_Asociated_HFO(stru_MergData,stru_MergFeat,str_Bol,str_Feat)

v_BarPlot = [];
v_Erro = [];

v_B_Bag=[];
v_S_Bag=[];
v_T_Bag=[];

v_B_A_Bag=[];
v_S_A_Bag=[];
v_T_A_Bag=[];


for i = 1:numel(stru_MergData)

    v_PID_B = stru_MergData(i).PID_B;
    v_PID_E = stru_MergData(i).PID_E;
    v_HFO_B = stru_MergData(i).HFO_B;
    v_HFO_E = stru_MergData(i).HFO_E;

    [v_Idx_PID,v_Idx_PID_No,~] = f_Asocia_PID_HFO (v_PID_B,v_PID_E,v_HFO_B,v_HFO_E);

    switch str_Feat

        case 'A'
            v_Feat_C = stru_MergFeat(i).PID_A;
        case 'D'
            v_Feat_C = stru_MergFeat(i).PID_D;
        case 'S'
            v_Feat_C = stru_MergFeat(i).PID_slope;   
    end

    v_Ax_C = stru_MergData(i).PID_B;

    v_Feat_HFO = v_Feat_C(v_Idx_PID);
    v_Feat_NO_HFO = v_Feat_C(v_Idx_PID_No);

    v_Ax_HFO = v_Ax_C(v_Idx_PID);
    v_Ax_NO_HFO = v_Ax_C(v_Idx_PID_No);

    s_S = stru_MergData(i).SS;
    s_T = stru_MergData(i).TG;

    if strcmp(str_Bol,'HFO')

        v_Axis = v_Ax_HFO;
        v_Feat = v_Feat_HFO;

    elseif strcmp(str_Bol,'NOHFO')

        v_Axis = v_Ax_NO_HFO;
        v_Feat = v_Feat_NO_HFO; 

    end

    %% Points plot

    v_Feat = (v_Feat-min(v_Feat))./(max(v_Feat)-min(v_Feat)); % aca se vuelven NaN si el v_Feat no tiene mas de 2 elementos

    if isnan(v_Feat)
        continue
    end
    

    % Build up

    v_Sel = v_Axis<s_S;

    v_B_Ax = v_Axis(v_Sel);
    v_B_Ft = v_Feat(v_Sel);

    if ~isempty(v_B_Ax)
        v_B_Ax = (v_B_Ax-min(v_B_Ax))/(max(v_B_Ax)-min(v_B_Ax));
    end


    % Steady state

    v_Sel = v_Axis>=s_S & v_Axis<s_T;

    v_S_Ax = v_Axis(v_Sel);
    v_S_Ft = v_Feat(v_Sel);

    if ~isempty(v_S_Ax)
        v_S_Ax = (v_S_Ax-min(v_S_Ax))/(max(v_S_Ax)-min(v_S_Ax));
    end


    %Trigger

    v_Sel = v_Axis>=s_T;

    v_T_Ax = v_Axis(v_Sel);
    v_T_Ft = v_Feat(v_Sel);

    if ~isempty(v_T_Ax)
        v_T_Ax = (v_T_Ax-min(v_T_Ax))/(max(v_T_Ax)-min(v_T_Ax));
    end

    v_B_A_Bag=[v_B_A_Bag,v_B_Ax];
    v_S_A_Bag=[v_S_A_Bag,v_S_Ax];
    v_T_A_Bag=[v_T_A_Bag,v_T_Ax];

    v_B_Bag=[v_B_Bag,v_B_Ft];
    v_S_Bag=[v_S_Bag,v_S_Ft];
    v_T_Bag=[v_T_Bag,v_T_Ft];

end
    %% Bar plot

    s_Size_B = floor(numel(v_B_A_Bag)/10);
    s_Size_S = floor(numel(v_S_A_Bag)/10);
    s_Size_T = floor(numel(v_T_A_Bag)/3);

    % Build up bar

    [~,s_IndxSort]=sort(v_B_A_Bag);
    v_Use = v_B_Bag(s_IndxSort);

    s_Inf = 1;

    for i=1:10

        s_Sup = s_Inf+s_Size_B;

        try
            v_Temp = v_Use(s_Inf:s_Sup);
        catch
            v_Temp = v_Use(s_Inf:numel(v_Use));
        end
        v_Temp(v_Temp==Inf)=[];
        v_Mean_B(i) = mean(v_Temp);
        v_STD_B(i) = std(v_Temp);
        %v_STD_B(i) = std(v_Temp)/sqrt(numel(v_Temp));

        stru_Joint(i).BU = v_Temp;

        s_Inf = s_Sup+1;

    end

    % Steady bar

    [~,s_IndxSort]=sort(v_S_A_Bag);
    v_Use = v_S_Bag(s_IndxSort);

    s_Inf = 1;

    for i=1:10

        s_Sup = s_Inf+s_Size_S;

        try
            v_Temp = v_Use(s_Inf:s_Sup);
        catch
            v_Temp = v_Use(s_Inf:numel(v_Use));
        end
        v_Temp(v_Temp==Inf)=[];
        v_Mean_S(i) = mean(v_Temp);
        v_STD_S(i) = std(v_Temp);
        %v_STD_S(i) = std(v_Temp)/sqrt(numel(v_Temp));
        stru_Joint(i).SS = v_Temp;

        s_Inf = s_Sup+1;

    end

    % Trigger

    [~,s_IndxSort]=sort(v_T_A_Bag);
    v_Use = v_T_Bag(s_IndxSort);

    s_Inf = 1;

    for i=1:3

        s_Sup = s_Inf+s_Size_T;

        try
            v_Temp = v_Use(s_Inf:s_Sup);
        catch
            v_Temp = v_Use(s_Inf:numel(v_Use));
        end
        v_Temp(v_Temp==Inf)=[];
        v_Mean_T(i) = mean(v_Temp);
        v_STD_T(i) = std(v_Temp);
        %v_STD_T(i) = std(v_Temp)/sqrt(numel(v_Temp));
        stru_Joint(i).TG = v_Temp;
        s_Inf = s_Sup+1;

    end

    v_BarPlot = [v_Mean_B,v_Mean_S,v_Mean_T];
    v_Erro = [v_STD_B,v_STD_S,v_STD_T];

end