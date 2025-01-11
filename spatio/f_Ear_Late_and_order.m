function [v_Early_Out,v_Late_Out,v_Order_Out] = f_Ear_Late_and_order(m_Concu,v_PksSearch)

s_Win = 1600;

v_EarlyAll=[];
v_LateAll=[];

for x = 1:numel(v_PksSearch)

    s_LimInf = v_PksSearch(x)-(s_Win/2);
    s_LimSup = v_PksSearch(x)+(s_Win/2);

    v_Use = [];
    for d=1:length(m_Concu)
        if m_Concu(d,1)>= s_LimInf && m_Concu(d,1)<= s_LimSup
            v_Use(d)= 1;
        else
            v_Use(d)= 0;
        end
    end

    m_Temp = m_Concu(logical(v_Use),:);
    m_Temp_Sort = sortrows(m_Temp,1);

    s_Ten = round(0.1*length (m_Temp_Sort));
    v_Early = m_Temp_Sort(1:s_Ten,2);
    v_Late = m_Temp_Sort(end-s_Ten+1:end,2);
    v_Order = m_Temp_Sort(:,2);

    for h=1:120
        try
            m_ElecOrder(h,x) = find(v_Order==h);
        catch
            m_ElecOrder(h,x) = nan;
        end
    end

    v_EarlyAll = [v_EarlyAll;v_Early];
    v_LateAll = [v_LateAll;v_Late];

end

s_Five = round(s_Ten/2);

[v_Ocu,v_Ele] = histcounts(v_EarlyAll,1:121);

[~,v_IndxMax] = sort(v_Ocu, 'descend');
v_IndxMax = v_IndxMax(1:s_Five);
v_Early_Out = v_Ele(v_IndxMax);

[v_Ocu,v_Ele] = histcounts(v_LateAll,1:121);

[~,v_IndxMax] = sort(v_Ocu, 'descend');
v_IndxMax = v_IndxMax(1:s_Five);
v_Late_Out = v_Ele(v_IndxMax);

v_Order_Out = mean(m_ElecOrder,2);

end