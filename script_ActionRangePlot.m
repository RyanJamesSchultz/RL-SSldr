% Script that plots the range of actions required to win the spring-slider game.
clear;

% Predefine some variables.
FileName1='AlgoRein_v24.mat'; N1=62;
FileName2='AlgoRein_v44.mat'; N2=51;
FileName3='AlgoRein_rec.mat'; N3=71;

% Define the environment, load/do the numerical reining steps.
load(FileName1,'expBatch','logVs');
expBatch1=expBatch;
for i1=1:N1
    a=expBatch1(i1).Action{1};
    A1(i1)=a(2);
end

% Define the environment, load/do the numerical reining steps.
load(FileName2,'expBatch','logVs');
expBatch2=expBatch;
for i2=1:N2
    a=expBatch2(i2).Action{1};
    A2(i2)=a(2);
end

% Define the environment, load/do the numerical reining steps.
load(FileName3,'expBatch','logVs');
expBatch3=expBatch;
for i3=1:N3
    a=expBatch3(i3).Action{1};
    A3(i3)=a(2);
end

% Plot.
figure(5); clf;
plot(0:N1-1,A1,'-b'); hold on;
plot(0:N2-1,A2,':b');
plot(0:N3-1,A3,'--b');
plot(30*[1 1],ylim(),'-k'); % Struggle point.
xlabel('Step number'); ylabel('dP/dt log_{10}[MPa/s]');