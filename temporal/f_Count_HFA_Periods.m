function [v_BarHFA,v_BarNoHFA] = f_Count_HFA_Periods(stru_MergData)

v_B_1_Bag=[];
v_S_1_Bag=[];
v_T_1_Bag=[];

v_B_2_Bag=[];
v_S_2_Bag=[];
v_T_2_Bag=[];

for i = 1:25

    v_PID_B = stru_MergData(i).PID_B;
    v_PID_E = stru_MergData(i).PID_E;
    v_HFA_B = stru_MergData(i).HFA_B;
    v_HFA_E = stru_MergData(i).HFA_E;

    [v_Idx_PID,v_Idx_PID_No,~] = f_Asocia_PID_HFA (v_PID_B,v_PID_E,v_HFA_B,v_HFA_E);

    v_Ax_C = stru_MergData(i).PID_B;
   
    v_Ax_HFA = v_Ax_C(v_Idx_PID);
    v_Ax_NO_HFA = v_Ax_C(v_Idx_PID_No);

    s_S = stru_MergData(i).SS;
    s_T = stru_MergData(i).TG;


    % Build up

    v_Sel1 = v_Ax_HFA<s_S;
    v_Sel2 = v_Ax_NO_HFA<s_S;

    v_B_Ax1 = v_Ax_HFA(v_Sel1);
    v_B_Ax2 = v_Ax_NO_HFA(v_Sel2);

    if ~isempty(v_B_Ax1)
        v_B_Ax1 = (v_B_Ax1-min(v_B_Ax1))/(max(v_B_Ax1)-min(v_B_Ax1));
    end

    if ~isempty(v_B_Ax2)
        v_B_Ax2 = (v_B_Ax2-min(v_B_Ax2))/(max(v_B_Ax2)-min(v_B_Ax2));
    end

    % Steady state

    v_Sel1 = v_Ax_HFA>=s_S & v_Ax_HFA<s_T;
    v_Sel2 = v_Ax_NO_HFA>=s_S & v_Ax_NO_HFA<s_T;

    v_S_Ax1 = v_Ax_HFA(v_Sel1);
    v_S_Ax2 = v_Ax_NO_HFA(v_Sel2);

    if ~isempty(v_S_Ax1)
        v_S_Ax1 = (v_S_Ax1-min(v_S_Ax1))/(max(v_S_Ax1)-min(v_S_Ax1));
    end

    if ~isempty(v_S_Ax2)
        v_S_Ax2 = (v_S_Ax2-min(v_S_Ax2))/(max(v_S_Ax2)-min(v_S_Ax2));
    end

    %Trigger

    v_Sel1 = v_Ax_HFA>=s_T;
    v_Sel2 = v_Ax_NO_HFA>=s_T;

    v_T_Ax1 = v_Ax_HFA(v_Sel1);
    v_T_Ax2 = v_Ax_NO_HFA(v_Sel2);

     if ~isempty(v_T_Ax1)
        v_T_Ax1 = (v_T_Ax1-min(v_T_Ax1))/(max(v_T_Ax1)-min(v_T_Ax1));
    end

    if ~isempty(v_T_Ax2)
        v_T_Ax2 = (v_T_Ax2-min(v_T_Ax2))/(max(v_T_Ax2)-min(v_T_Ax2));
    end


    v_B_1_Bag=[v_B_1_Bag,v_B_Ax1];
    v_S_1_Bag=[v_S_1_Bag,v_S_Ax1];
    v_T_1_Bag=[v_T_1_Bag,v_T_Ax1];

    v_B_2_Bag=[v_B_2_Bag,v_B_Ax2];
    v_S_2_Bag=[v_S_2_Bag,v_S_Ax2];
    v_T_2_Bag=[v_T_2_Bag,v_T_Ax2];
    
end

v_Loop = linspace(0,1,11);

for d=1:numel(v_Loop)-1

    s_InfL = v_Loop(d);
    s_SupL = v_Loop(d+1);

    v_NumB_HFA(d) = sum(v_B_1_Bag> s_InfL & v_B_1_Bag<= s_SupL);
    v_NumB_NoHFA(d) = sum(v_B_2_Bag> s_InfL & v_B_2_Bag<= s_SupL);

    v_NumS_HFA(d) = sum(v_S_1_Bag> s_InfL & v_S_1_Bag<= s_SupL);
    v_NumS_NoHFA(d) = sum(v_S_2_Bag> s_InfL & v_S_2_Bag<= s_SupL);

end

v_Loop = linspace(0,1,4);

for d=1:numel(v_Loop)-1

    s_InfL = v_Loop(d);
    s_SupL = v_Loop(d+1);

    v_NumT_HFA(d) = sum(v_T_1_Bag> s_InfL & v_T_1_Bag<= s_SupL);
    v_NumT_NoHFA(d) = sum(v_T_2_Bag> s_InfL & v_T_2_Bag<= s_SupL);

end

v_BarHFA = [v_NumB_HFA,v_NumS_HFA,v_NumT_HFA];
v_BarNoHFA = [v_NumB_NoHFA,v_NumS_NoHFA,v_NumT_NoHFA];

end