function [v_Stats] = f_DivideBinsStats (v_Feat,v_Axis,s_NBins)

v_Div = linspace(0,1,s_NBins+1);
v_Stats = [];

for j=1:numel(v_Div)-1

    s_Inf = v_Div(j);
    s_Sup = v_Div(j+1);
    v_Bol = v_Axis>=s_Inf & v_Axis<s_Sup;

    if sum (v_Bol)==0
        v_Stats(j) = 0;
    else
        v_Stats(j) = mean(v_Feat(v_Bol));
    end

end

end