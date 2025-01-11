function [v_Idx_PID,v_Idx_PID_No,stru_Idx_Aso] = f_Asocia_PID_HFO(v_PID_B,v_PID_E,v_HFO_B,v_HFO_E)

v_Idx_PID_No = [];
stru_Idx_Aso = [];

% Asociar cada HFA a una PID

for i = 1:numel(v_PID_B)
    
    s_Inf = v_PID_B(i);
    s_Sup = v_PID_E(i);
    %v_Search = s_Inf:s_Sup;
    v_Search = s_Inf-600:s_Sup+600;

    v_HFO_Indx = [];

    for j=1:numel(v_HFO_B)

        s_HFO_B = v_HFO_B(j);
        s_HFO_E = v_HFO_E(j);

        if (min(abs(v_Search - s_HFO_B)) == 0) && (min(abs(v_Search - s_HFO_E)) == 0)
            s_HFO_Ind = j;            
        else
            s_HFO_Ind = 0;                
        end          

        v_HFO_Indx(j) = logical(s_HFO_Ind);

    end

    if sum(v_HFO_Indx)==0
        v_Idx_PID_No(i) = 1;
        stru_Idx_Aso(i).IndxHFO = [];
        continue
    else
        v_Idx_PID_No(i) = 0;
        stru_Idx_Aso(i).IndxHFO = find(v_HFO_Indx==1);
    end

end

v_Idx_PID_No = logical(v_Idx_PID_No);
v_Idx_PID = ~v_Idx_PID_No;

end