function [s_Freq] = f_PreFourier(v_Seg,s_SampRate,v_FreqL)

s_L = length(v_Seg);
v_Y = fft(v_Seg);
v_P2 = abs(v_Y/s_L);
v_P1 = v_P2(1:s_L/2+1);
v_P1(2:end-1) = 2*v_P1(2:end-1);

v_f = s_SampRate*(0:(s_L/2))/s_L;

s_IndxI = find(v_f>=v_FreqL(1),1);
s_IndxS = find(v_f>=v_FreqL(2),1);
[~,b] = max(v_P1(s_IndxI:s_IndxS));

s_Freq = v_f(s_IndxI+b-1);

% plot(v_f,v_P1) 
% title('Single-Sided Amplitude Spectrum of X(t)')
% xlabel('f (Hz)')
% ylabel('|P1(f)|')


end