function [v_corIdx_B,v_corIdx_E] = f_ManuallyCorrec_TS(v_Data,v_Idx_B,v_Idx_E,v_HFO_F,str_Ana)

s_LeftValSec = [];
s_RightValSec = [];
s_Wind = 1500;

if strcmp(str_Ana,'PID')

    for i= 1:numel(v_Idx_B)

        try
            v_Seg = v_Data(v_Idx_B(i)-s_Wind:v_Idx_E(i)+s_Wind);
        catch
            v_corIdx_B(i) = nan;
            v_corIdx_E(i) = nan;

            continue
        end

        f = figure('Position',[975, 435,560,420]);

        %         v_Seg = abs(v_Seg);
        s_Len = length(v_Seg);
        plot(v_Seg,'k')
        hold on
        plot(s_Wind,v_Seg(s_Wind),'ob','MarkerSize',5,'MarkerFaceColor','b')
        plot(length(v_Seg)-s_Wind,v_Seg(s_Len-s_Wind),'or','MarkerSize',5,'MarkerFaceColor','r')
        title(strcat(num2str(i),{' '}, 'of',{' '},num2str(numel(v_Idx_B))))
        f_Cursors()
        s_DiffIni = s_Wind-floor(s_LeftValSec);
        s_DiffFin = (s_Len-s_Wind)-floor(s_RightValSec);

        v_corIdx_B(i) = v_Idx_B(i)-s_DiffIni;
        v_corIdx_E(i) = v_Idx_E(i)-s_DiffFin;

    end

elseif strcmp(str_Ana,'HFA')

    Fs = 10000;  % Sampling Frequency

    N      = 70;   % Order
    Fstop1 = 100;  % First Stopband Frequency
    Fstop2 = 600;  % Second Stopband Frequency
    Astop  = 80;   % Stopband Attenuation (dB)

    h  = fdesign.bandpass('N,Fst1,Fst2,Ast', N, Fstop1, Fstop2, Astop, Fs);
    Hd = design(h, 'cheby2');

    v_FilHigh = filter(Hd,v_Data);
    v_Data = flip(filter(Hd, flip(v_FilHigh)));

    % Envelope of the high filtered signal
    v_Envelope = abs(hilbert(v_Data));

    % Low pass envelope filtering

    Nfir = 70;
    Fst = 40;
    firf = designfilt('lowpassfir','FilterOrder',Nfir, ...
        'CutoffFrequency',Fst,'SampleRate',Fs);

    v_FilEnve = filter(firf,v_Envelope);
    v_FilEnve = flip(filter(firf, flip(v_FilEnve)));


    for i= 1:numel(v_Idx_B)

        try
            v_Seg = v_Data(v_Idx_B(i)-s_Wind:v_Idx_E(i)+s_Wind);
        catch
            v_corIdx_B(i) = nan;
            v_corIdx_E(i) = nan;

            continue
        end

        f = figure('Position',[975, 435,560,420]);
        s_Len = length(v_Seg);
        plot(v_Seg,'k')
        hold on
        plot(v_FilEnve(v_Idx_B(i)-s_Wind:v_Idx_E(i)+s_Wind),'m')
        plot(s_Wind,v_Seg(s_Wind),'ob','MarkerSize',5,'MarkerFaceColor','b')
        plot(length(v_Seg)-s_Wind,v_Seg(s_Len-s_Wind),'or','MarkerSize',5,'MarkerFaceColor','r')

        v_TemSeg = v_Seg(s_Wind:length(v_Seg)-s_Wind);
        [s_AMax,s_Max] = max(v_TemSeg);
        plot(s_Wind+s_Max,s_AMax,'ok','MarkerSize',5,'MarkerFaceColor','k')

        title(strcat(num2str(i),{' '}, 'of',{' '},num2str(numel(v_Idx_B))))
        f_Cursors()
        s_DiffIni = s_Wind-floor(s_LeftValSec);
        s_DiffFin = (s_Len-s_Wind)-floor(s_RightValSec);

        v_corIdx_B(i) = v_Idx_B(i)-s_DiffIni;
        v_corIdx_E(i) = v_Idx_E(i)-s_DiffFin;

    end

elseif strcmp(str_Ana,'HFO')

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

        v_Seg = v_Data(v_Idx_B(i)-s_Wind:v_Idx_E(i)+s_Wind);

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

        s_FreqTarget = v_HFO_F(i);

        Fstop1 = s_FreqTarget - 50;                                        % First Stopband Frequency
        Fstop2 = s_FreqTarget + 50;                                        % Second Stopband Frequency

        h  = fdesign.bandpass('N,Fst1,Fst2,Ast', N, Fstop1, Fstop2, Astop, 10000);
        fil_Spec = design(h, 'cheby2');

        v_Search = filter(fil_Spec,v_Seg);
        v_Search = flip(filter(fil_Spec, flip(v_Search)));
        v_SearchEnv = abs(hilbert(v_Search));

        f = figure('Position',[975, 435,560,420]);
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

        f_Cursors()
        s_DiffIni = s_Wind-floor(s_LeftValSec);
        s_DiffFin = (s_Len-s_Wind)-floor(s_RightValSec);

        v_corIdx_B(i) = v_Idx_B(i)-s_DiffIni;
        v_corIdx_E(i) = v_Idx_E(i)-s_DiffFin;

    end

end

v_corIdx_B(isnan(v_corIdx_B))=[];
v_corIdx_E(isnan(v_corIdx_E))=[];


    function f_Cursors (~,~)

        try
            delete (l_CurOne)
            delete (l_CurTwo)
        catch

        end
        s_button = 1;
        s_ConLeft = 0;

        while s_button ~= 3                                                % Read ginputs until a mouse right-button occurs
            [x,~,s_button] = ginput(1);

            if s_button == 1
                s_LeftValSec = x;
                s_ConLeft = s_ConLeft + 1;

                if s_ConLeft == 1
                    l_CurOne = xline(s_LeftValSec,'b');
                    set(l_CurOne,'linewidth',1.2)
                else
                    delete (l_CurOne)
                    l_CurOne = xline(s_LeftValSec,'b');
                    set(l_CurOne,'linewidth',1.2)
                end

            elseif s_button == 3
                s_RightValSec = x;
                l_CurTwo = xline(s_RightValSec,'r');
                set(l_CurTwo,'linewidth',1.2)
                st_hIcons.Cursors.State = 'off';

            elseif s_button == 114

                try
                    delete (l_CurOne)
                    delete (l_CurTwo)
                catch

                end
                s_LeftValSec = nan;
                s_RightValSec = nan;
                break


            elseif s_button == 32

                try
                    delete (l_CurOne)
                    delete (l_CurTwo)
                catch

                end
                s_LeftValSec = s_Wind;
                s_RightValSec = s_Len-s_Wind;
                break

            end

        end

        pause(0.2)
        close(f)

    end



end