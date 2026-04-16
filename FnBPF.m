function y=FnBPF(x,fs,Band)

x=x(:); Rp=1; Rs=80;

Wp=band/(fs/2);
Ws=[0.9*Band(1) 1.1*band(2)]/(fs/2);

[n,Wn]=cheb2ord(Wp,Ws,Rp,Rs);
[sos,g]=tf2sos(cheby2(n,Rs,Wn,'bandpass'));

y=filtfilt(sos,g,x);

end