function XFilt=FnBPF_ChebyII(x,fs,Band)
Astop=80;        % stopband attenuation (dB)
f1=Band(1);
f2=Band(2);
% Define stopband edges (10% outside passband)
fs1=0.9 * f1;        % lower stopband edge
fs2=1.1 * f2;        % upper stopband edge

% Normalize frequencies (Nyquist = fs/2)
Wp = [f1 f2] / (fs/2);     % passband
Ws = [fs1 fs2] / (fs/2);   % stopband

% Ensure valid bounds
Ws(1) = max(Ws(1), 0);
Ws(2) = min(Ws(2), 1);

% Design Chebyshev Type II filter
[n,Wn]=cheb2ord(Wp,Ws,1,Astop);   % .5 dB passband ripple (typical placeholder)
[A,B,C,D]=cheby2(n,Astop,Wn);

[sos,g] = ss2sos(A,B,C,D);

% [sos, g] = tf2sos(b, a);
XFilt = filtfilt(sos, g,x);

fvtool(sos,'Fs', fs);
% % Optional: inspect frequency response
% freqz(b,a,1024,fs);
title('Chebyshev Type II Bandpass Filter');

end