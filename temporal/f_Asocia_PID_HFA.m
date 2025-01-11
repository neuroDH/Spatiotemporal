function [v_Idx_PID,v_Idx_PID_No,v_Idx_Aso] = f_Asocia_PID_HFA(v_PID_B,v_PID_E,v_HFA_B,v_HFA_E)

v_Idx_PID_No = [];
v_Idx_Aso = [];

% Asociar cada HFA a una PID

for i = 1:numel(v_PID_B)
    
    s_Inf = v_PID_B(i);
    s_Sup = v_PID_E(i);
    v_Search = s_Inf:s_Sup;

    v_HFA_Indx = [];

    for j=1:numel(v_HFA_B)

        s_HFA_B = v_HFA_B(j);
        s_HFA_E = v_HFA_E(j);

        if (min(abs(v_Search - s_HFA_B)) == 0) || min(abs(v_Search - s_HFA_E)) == 0
            s_HFA_Ind = j;            
        else
            s_HFA_Ind = 0;                
        end          

        v_HFA_Indx(j) = logical(s_HFA_Ind);

    end

    if sum(v_HFA_Indx)==0
        v_Idx_PID_No(i) = 1;
        continue
    else
        v_Idx_PID_No(i) = 0;
        v_Idx_Aso(i)=find(v_HFA_Indx==1);
    end

end

v_Idx_PID_No = logical(v_Idx_PID_No);
v_Idx_PID = ~v_Idx_PID_No;

end