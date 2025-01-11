clear;close all;clc
load('Features2Plot_Win.mat','stru_Sort_PID')

s_NumWinJo = 5;
cont = 1;

for i=1:s_NumWinJo:numel(stru_Sort_PID)-3

    v_Indx = []; v_Elec = []; v_PIDO = []; v_HFAO = [];v_HFOO = [];...
        v_PIDA = []; v_EL = [];

    for j= i:i+4

        v_IndxT = stru_Sort_PID(j).Indx;
        v_ElecT = stru_Sort_PID(j).Elec;
        v_PIDOT = stru_Sort_PID(j).PIDOcu;
        v_HFAOT = stru_Sort_PID(j).HFAOcu;
        v_HFOOT = stru_Sort_PID(j).HFOOcu;
        v_PIDAT = stru_Sort_PID(j).PIDAmp;
        v_ELT = stru_Sort_PID(j).EarLate;

        v_Indx = [v_Indx;v_IndxT];
        v_Elec = [v_Elec;v_ElecT];
        v_PIDO = [v_PIDO;v_PIDOT];
        v_HFAO = [v_HFAO;v_HFAOT];
        v_HFOO = [v_HFOO;v_HFOOT];
        v_PIDA = [v_PIDA;v_PIDAT];
        v_EL = [v_EL;v_ELT];

    end

    [v_ElecUniq, ~] = unique(v_Elec, 'stable');
    v_PIDO_Uni = zeros(size(v_ElecUniq));
    v_HFAO_Uni = zeros(size(v_ElecUniq));
    v_HFOO_Uni = zeros(size(v_ElecUniq));
    v_PIDA_Uni = zeros(size(v_ElecUniq));
    v_INDT_Uni = zeros(size(v_ElecUniq));
    
    for k = 1:length(v_ElecUniq)
        v_idxRep = find(v_Elec == v_ElecUniq(k));
        v_PIDO_Uni(k) = any(v_PIDO(v_idxRep));
        v_HFAO_Uni(k) = any(v_HFAO(v_idxRep));
        v_HFOO_Uni(k) = any(v_HFOO(v_idxRep));
        v_PIDA_Uni(k) = mean(v_PIDA(v_idxRep));
        v_INDT_Uni(k) = mean(v_Indx(v_idxRep));
    end

    v_EL_Uni = zeros(size(v_ElecUniq))+2;
    s_counts_E = histcounts(v_Elec(v_EL==3), 1:121); % 3 early
    s_counts_L = histcounts(v_Elec(v_EL==1), 1:121); % 1 late

    [~, v_top_5_E] = sort(s_counts_E, 'descend');
    v_Early = v_top_5_E(1:5);

    [~, v_top_5_L] = sort(s_counts_L, 'descend');
    v_Late = v_top_5_L(1:5);

    for z = 1:length(v_ElecUniq)

        s_ElecUni = v_ElecUniq(z);

        if ismember(s_ElecUni, v_Early)
            v_EL_Uni(z) = 3;
        elseif ismember(s_ElecUni, v_Late)
            v_EL_Uni(z) = 1;
        else
            continue
        end
    end

    stru_Win_PID(cont).Indx = v_INDT_Uni;
    stru_Win_PID(cont).Elec = v_ElecUniq;
    stru_Win_PID(cont).PIDOcu = v_PIDO_Uni;
    stru_Win_PID(cont).HFAOcu = v_HFAO_Uni;
    stru_Win_PID(cont).HFOOcu = v_HFOO_Uni;
    stru_Win_PID(cont).PIDAmp = v_PIDA_Uni;
    stru_Win_PID(cont).EarLate = v_EL_Uni;
    cont = cont+1;
end

save('Features2Plot_Uni.mat','stru_Win_PID')
