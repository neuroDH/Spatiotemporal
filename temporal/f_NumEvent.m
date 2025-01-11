function [v_B_cont,v_S_cont,v_T_cont] = f_NumEvent (v_Event,s_SS,s_TG,s_End)

% v_Event = stru_MergData(2).HFA_B;
% s_SS = stru_MergData(2).SS;
% s_TG = stru_MergData(2).TG;
% s_End = stru_MergData(2).N_Samp;

% Build-up

v_Bar_B = floor(linspace(0,s_SS,25));

for i = 1:10
    
    s_Inf = v_Bar_B(i)+1;
    s_Sup = v_Bar_B(i+1);
    
    v_B_cont(i) = sum(v_Event>=s_Inf & v_Event<=s_Sup);
end

% Steady

v_Bar_S = floor(linspace(s_SS,s_TG,11));

for i = 1:10
    
    s_Inf = v_Bar_S(i)+1;
    s_Sup = v_Bar_S(i+1);
    
    v_S_cont(i) = sum(v_Event>=s_Inf & v_Event<=s_Sup);
    
end

% Trigger

v_Bar_T = floor(linspace(s_TG,s_End,3));

for i = 1:3
    
    s_Inf = v_Bar_T(i)+1;
    s_Sup = v_Bar_T(i+1);
    
    v_T_cont(i) = sum(v_Event>=s_Inf & v_Event<=s_Sup);
    
end

end