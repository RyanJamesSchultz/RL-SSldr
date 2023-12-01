% Trying to get handle on how quickly exploration noise should decay for DDPG (and TD3).
% https://ch.mathworks.com/help/reinforcement-learning/ref/rl.option.rlddpgagentoptions.html
clear;

% The set of input parameters.
StandardDeviation = [0.1;0.05];
StandardDeviationDecayRate = 1e-5;
MeanAttractionConstant=0.30;
Mean=0;
n=50;
Ns=100;
Ts=1;

% The half-life decay of SD with episode number.
halflife = log(0.5)/log(1-StandardDeviationDecayRate);
SD1t=2*StandardDeviation(1)*cumprod(ones([1 n])/2);
SD2t=2*StandardDeviation(2)*cumprod(ones([1 n])/2);
t=halflife*((1:n)-1);

% The OU noise by step number, within an episode.
v=zeros([1 Ns]);
v(1)=0.0;
for i=1:(Ns-1)
    v(i+1) = v(i) + MeanAttractionConstant.*(Mean - v(i)).*Ts + StandardDeviation(2).*randn(size(Mean)).*sqrt(Ts);
end



% Plot.
figure(4); clf;
% SD vs episode number.
subplot(211);
semilogy(t,SD1t,'-x','DisplayName','Pressure Magnitude'); hold on;
semilogy(t,SD2t,'-x','DisplayName','Pressure Rate');
xlim([0 2e6]);
ylim([5e-5 5e0]);
semilogy(xlim(), 0.03*[1 1],':k','HandleVisibility','off');
xlabel('Episodes');
ylabel('Parameter Standard Deviation');
legend();
% OU noise vs step number.
subplot(212);
plot(1:Ns,v);
xlabel('Step Number');
ylabel('Parameter Standard Deviation');



