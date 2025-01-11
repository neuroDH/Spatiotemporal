function f_ImageMultiComp (m_PValues,s_Sig)

m_Plot = [];
[r,~] = size(m_PValues);

for i=1:r

    if m_PValues(i,6)< s_Sig
        m_Plot(m_PValues(i,1),m_PValues(i,2)) = 1;
        m_Plot(m_PValues(i,2),m_PValues(i,1)) = 1;
    else
        m_Plot(m_PValues(i,1),m_PValues(i,2)) = 0;
        m_Plot(m_PValues(i,2),m_PValues(i,1)) = 0;
    end

end

s_Num = sqrt(numel(m_Plot));

figure('Position',[1482	234	866	706])
imagesc(m_Plot)

end

