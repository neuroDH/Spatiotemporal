function [s_Amp] = f_HFOAmp(v_Seg,s_SampRate,v_LimFil)

Fstop1 = v_LimFil(1);                                                      % First Stopband Frequency
Fstop2 = v_LimFil(2);                                                      % Second Stopband Frequency

N      = 70;
Astop  = 80;

h  = fdesign.bandpass('N,Fst1,Fst2,Ast', N, Fstop1, Fstop2, Astop, s_SampRate);
fil_Spec = design(h, 'cheby2');

v_Search = filter(fil_Spec,v_Seg);
v_Search = flip(filter(fil_Spec, flip(v_Search)));
v_SearchEnv = abs(hilbert(v_Search));

s_Amp = max(v_SearchEnv);


end