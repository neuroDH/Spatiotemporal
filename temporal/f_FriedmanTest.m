function [s_Fr,s_EV,s_pval] = f_FriedmanTest(m_Data, s_Sig)

%% Friedman test

% Get num repetitions and groups
[b,k] = size(m_Data);

m_Cat = [];

% Rank data

for i=1:b
    v_Temp = m_Data(i,:);
    [~,h]=sort(v_Temp);
    m_Cat(i,:) = h;    
end

%Sum rank each group
v_Rank = sum(m_Cat);

% Get Friedman test stat (critical value)
s_Fr = (12/(b*k*(k+1)))*(sum(v_Rank.^2))-(3*b*(k+1));

% Load Chi^2 expected prob table
load('Chi2_Dis.mat','stru_Chi')

v_Deg = stru_Chi.FD;
v_Sig = stru_Chi.SL;
m_Chi = stru_Chi.Dist;

% Look for expected value in the Chi2 distribution
s_IndxDeg = find(v_Deg == k-1);
s_IndxSig = find(v_Sig == s_Sig);

if isempty(s_IndxDeg)|| isempty(s_IndxSig)
    disp('Freedom degrees or significance level not available, can not compare Chi-sq with expected value ');
    s_EV = [];
else
    s_EV = m_Chi(s_IndxDeg,s_IndxSig);
    
    if s_Fr < s_EV
        
        disp('H0 could not be rejected')
        disp('H1 is not suported')
        disp('No difference had been found between groups with this significance level')
        
    elseif s_Fr > s_EV
        
        disp('H0 is rejected')
        disp('then H1 is supported')
        disp('There are differences between groups with this significance level')
    end
    
end

%% Get P value

% Build cumulative density probability function

s_NumEle = 100000; 
v_x = linspace(0,2*s_Fr,s_NumEle);
v_CDF = zeros(size(v_x));
s_k = v_Deg(s_IndxDeg);

for i = 2:length(v_x)
    
    % Compute function value between interval range
    f_a = (1 / (2^(s_k/2) * gamma(s_k/2))) * v_x(i-1)^(s_k/2 - 1) * exp(-v_x(i-1) / 2);
    f_b = (1 / (2^(s_k/2) * gamma(s_k/2))) * v_x(i)^(s_k/2 - 1) * exp(-v_x(i) / 2);
    
    % Use trap aproach to conpute discrete integral
    v_CDF(i) = v_CDF(i - 1) + (v_x(i) - v_x(i - 1)) * (f_a + f_b) / 2;
end

% Norm CDF
v_CDF = v_CDF/v_CDF(end);

% % Plot CDF
% figure()
% plot(v_x, v_CDF);
% xlabel('Valores');
% ylabel('Probabilidad Acumulada');
% title(['Distribución de Probabilidad Acumulada (CDF) - Chi-cuadrado con ', num2str(s_k), ' grados de libertad']);

% Find p-value

s_Fr_PIndx =find((v_x-s_Fr)==min((abs(v_x-s_Fr))));
s_pval = 1-v_CDF(s_Fr_PIndx);
%p = friedman(m_Data,1)
%[p,tbl,stats] = friedman(m_Data,1)

end