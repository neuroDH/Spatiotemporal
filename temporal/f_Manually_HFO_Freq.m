function [v_FreqOut] = f_Manually_HFO_Freq(v_Data,v_Idx_B,v_Idx_E)

s_fre = [];
s_Wind = 1500;


% Wavelet parameters
s_MinFreqHz = 55;
s_MaxFreqHz = 650;
s_FreqSeg = 60;
s_NumOfCycles = 5;
s_Magnitudes = 1;
s_SquaredMag = 0;
s_MakeBandAve = 0;
s_Phases = 0;
s_TimeStep = [];

N      = 70;
Astop  = 80;

for i= 1:numel(v_Idx_B)

    try

        v_Seg = v_Data(v_Idx_B(i)-s_Wind:v_Idx_E(i)+s_Wind);

    catch
        v_FreqOut(i) = 0;
        continue
    end

    [m_Wav,~,v_Freq] = ...
        f_MorseAWTransformMatlab(...
        v_Seg, ...
        10000, ...
        s_MinFreqHz, ...
        s_MaxFreqHz, ...
        s_FreqSeg, ...
        s_NumOfCycles, ...
        s_Magnitudes, ...
        s_SquaredMag, ...
        s_MakeBandAve, ...
        s_Phases, ...
        s_TimeStep);

    %s_FreqTarget = v_HFO_F(i);
    s_FreqTarget = 250;

    Fstop1 = s_FreqTarget - 170;                                        % First Stopband Frequency
    Fstop2 = s_FreqTarget + 300;                                        % Second Stopband Frequency

    h  = fdesign.bandpass('N,Fst1,Fst2,Ast', N, Fstop1, Fstop2, Astop, 10000);
    fil_Spec = design(h, 'cheby2');

    v_Search = filter(fil_Spec,v_Seg);
    v_Search = flip(filter(fil_Spec, flip(v_Search)));
    v_SearchEnv = abs(hilbert(v_Search));

    f = figure();
    s_Len = length(v_Seg);

    a = subplot(2,1,1);
    plot(v_Search,'k')
    hold on
    plot(v_SearchEnv,'g')
    plot(s_Wind,v_SearchEnv(s_Wind),'ob','MarkerSize',5,'MarkerFaceColor','b')
    plot(length(v_SearchEnv)-s_Wind,v_SearchEnv(s_Len-s_Wind),'or','MarkerSize',5,'MarkerFaceColor','r')
    title(strcat(num2str(i),{' '}, 'of',{' '},num2str(numel(v_Idx_B))))
    legend(num2str(s_FreqTarget))

    b = subplot(2,1,2);
    f_ImageMatrix(m_Wav, 1:numel(v_SearchEnv), v_Freq, [],'hot',256);
    linkaxes([a,b],'x')
    xlim([0,numel(v_SearchEnv)])
    hold on
    xline([s_Wind,length(v_SearchEnv)-s_Wind],'g','LineWidth',1.2)

    f_Cursors()
    v_FreqOut(i) = s_fre;

end


    function f_Cursors (~,~)

        s_fre = [];
        s_button = 0;


        while s_button ~= 1                                                % Read ginputs until a mouse right-button occurs
            [~,freq,s_button] = ginput(1);

            if s_button == 1

                s_fre = freq;

            end

        end

        pause(0.2)
        close(f)

    end



end