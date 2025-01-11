function f_PlotHFO(s_Ini,s_Fin,v_RawData,v_LFP,s_SampRate)

addpath('./functions')

v_SegCom = v_RawData(s_Ini-1000:s_Fin+1000);
v_LFP = v_LFP(s_Ini-1000:s_Fin+1000);

N      = 80;   % Order
Fstop1 = 80;  % First Stopband Frequency
Fstop2 = 550;  % Second Stopband Frequency
Astop  = 95;   % Stopband Attenuation (dB)

h  = fdesign.bandpass('N,Fst1,Fst2,Ast', N, Fstop1, Fstop2, Astop,...      % Chebyshev Type II Bandpass IIR filter designed using FDESIGN.BANDPASS
    s_SampRate);
Hd = design(h, 'cheby2');

% Filter data (fordward and backward to avoid phase shift)

disp ('Filtering data...');
v_FilData = filter(Hd,v_SegCom);
v_FilData = flip(filter(Hd, flip(v_FilData)));

%% Hilbert transform (for compute the envelope)

disp ('Computing envelope...');
v_Hil = abs(hilbert(v_FilData));

%% Compute spectrogram

s_MinFreqHz = 55;
s_MaxFreqHz = 650;
s_FreqSeg = 60;
s_NumOfCycles = 5;
s_Magnitudes = 1;
s_SquaredMag = 0;
s_MakeBandAve = 0;
s_Phases = 0;
s_TimeStep = [];

disp ('Computing spectrogram...');
[m_MorseWT,~,v_FreqAxisOri] = ...
    f_MorseAWTransformMatlab(...
    v_SegCom, ...
    s_SampRate, ...
    s_MinFreqHz, ...
    s_MaxFreqHz, ...
    s_FreqSeg, ...
    s_NumOfCycles, ...
    s_Magnitudes, ...
    s_SquaredMag, ...
    s_MakeBandAve, ...
    s_Phases, ...
    s_TimeStep);

disp ('Ploting...');

v_Plot = v_SegCom;
s_B = 1000;
s_E = numel(v_Plot)-1000;
v_Ax = 1:numel(v_Plot);

subplot(3,1,1)
plot(v_Ax,v_LFP,'k')
hold on
plot(v_Ax,v_Plot,'b')
subplot(3,1,2)
plot(v_Ax,v_FilData,'k')
hold on
plot(v_Ax,v_Hil,'r')
subplot(3,1,3)
f_ImageMatrix(...
    m_MorseWT, ...
    v_Ax, ...
    v_FreqAxisOri, ...
    [], ...
    'hot', ...
    256, ...
    0, ...
    1, ...
    1, ...
    0)
hold on
xline([s_B,s_E],'m')

end