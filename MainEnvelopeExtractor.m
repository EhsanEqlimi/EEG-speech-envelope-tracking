clc;
clear;
close all;

%% Main script for extracting the envelope of acoustic (speech) signals
% using different methods. This code can be used for neural tracking of
% speech during listening experiments with EEG.
%
% Written by Ehsan Eqlimi, PhD
% PostDoc Researcher, Empenn Group, IRISA / INRIA, University of Rennes, France
% Email: eqlimi.ehsan@gmail.com
%% Load speech signal
[SpeechSig, SpeechFs]=audioread("Sounds\1-pink-goldenage_cal68.wav");
SpeechSig=mean(SpeechSig,2); % mono
Time=(0:length(SpeechSig)-1)/SpeechFs;
%% LPF params.
%Since I will band-pass filter (delta/theta) later, I can skip LPF after envelope.
f_LP=8; %(high cuttoff theta freq.)
%% BFP params
f_delta=[.5 4];
f_theta=[4 8];

%% Envelope extraction 
RectSpeech=abs(SpeechSig);
EnvRect=lowpass(RectSpeech,f_LP,SpeechFs);

SqSpeech=SpeechSig.^2;
EnvSq=lowpass(SqSpeech,f_LP,SpeechFs);

AbsHilbertSpeech=abs(hilbert(SpeechSig));
EnvHilbert=lowpass(AbsHilbertSpeech,f_LP,SpeechFs);

EnvPowLaw=lowpass(RectSpeech.^0.6,f_LP,SpeechFs);

EnvLog=lowpass(log(RectSpeech+eps),f_LP,SpeechFs);

%% Collect for unified ylim
allEnv=[EnvRect; EnvSq; EnvHilbert; EnvPowLaw];
yl=[min(allEnv) max(allEnv)];

%% Plot (compact, same ylim)
figure('Color','w','Position',[100 100 800 700]);

Titles={'Rectified + LPF','Squared + LPF','Hilbert+LPF','Power-law (0.6)+LPF','Log + LPF'};
Envs={EnvRect,EnvSq,EnvHilbert,EnvPowLaw,EnvLog};

for i=1:4
    subplot(5,1,i)
    plot(Time,Envs{i}, 'k', 'LineWidth', 1);
    ylim(yl)
    xlim([Time(1) Time(end)])
    
    title(Titles{i}, 'FontSize', 10)
    
    if i < 5
        set(gca, 'XTickLabel', [])
    else
        xlabel('Time (s)')
    end
    
    box off
end

%% Tight spacing (very compact)
set(gcf,'Units','normalized')
set(gca,'FontSize',9)

% Reduce gaps manually
ha=findall(gcf,'type','axes');
for i=1:length(ha)
    pos=get(ha(i),'Position');
    pos(4)=pos(4)*0.9; % shrink height slightly
    set(ha(i),'Position',pos);
end
%% Envelope + BPF (for EEG later analysis)
EnvRectDelta=FnBPF_ChebyII(RectSpeech,SpeechFs,f_delta);
EnvRectTheta=FnBPF_ChebyII(RectSpeech,SpeechFs,f_theta);


EnvSqDelta=FnBPF_ChebyII(SqSpeech,SpeechFs,f_delta);
EnvSqTheta=FnBPF_ChebyII(SqSpeech,SpeechFs,f_theta);

EnvAbsHilbertDelta=FnBPF_ChebyII(AbsHilbertSpeech,SpeechFs,f_delta);
EnvAbsHilbertTheta=FnBPF_ChebyII(AbsHilbertSpeech,SpeechFs,f_theta);
%% Plot Band-Pass Filtered Envelopes (Delta & Theta)

figure('Color','w','Position',[200 200 900 600]);

subplot(2,2,1)
plot(Time, EnvRectDelta, 'k', 'LineWidth', 1);
title('Rectified Envelope - Delta (0.5–4 Hz)')
xlabel('Time (s)'); box off; xlim([Time(1) Time(end)])

subplot(2,2,2)
plot(Time, EnvRectTheta, 'k', 'LineWidth', 1);
title('Rectified Envelope - Theta (4–8 Hz)')
xlabel('Time (s)'); box off; xlim([Time(1) Time(end)])

subplot(2,2,3)
plot(Time, EnvSqDelta, 'k', 'LineWidth', 1);
title('Squared Envelope - Delta (0.5–4 Hz)')
xlabel('Time (s)'); box off; xlim([Time(1) Time(end)])

subplot(2,2,4)
plot(Time, EnvSqTheta, 'k', 'LineWidth', 1);
title('Squared Envelope - Theta (4–8 Hz)')
xlabel('Time (s)'); box off; xlim([Time(1) Time(end)])

set(gca,'FontSize',9)
%4-Band-wise (gammatone filterbank)


