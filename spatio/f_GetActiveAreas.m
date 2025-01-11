function [v_ActiAreas] = f_GetActiveAreas(m_Data,stru_Score)

m_Area = stru_Score(1).AreasMat;
m_Temp = m_Data.*m_Area;
v_Areas = unique(m_Temp);
v_Areas(isnan(v_Areas))=[];
v_Areas(v_Areas==0)=[];

v_ActiAreas = v_Areas;

end