% Script to verify if constant velocity reined-slip produces exponential decay.
clear;

% Load in the dP vs T data from Figure 3.
load('AlgoRein_v24.mat','logVs');
load('PvT.mat','t2','P2','env2','I2','i2');
t2=t2-t2(1);

% Get the required variables.
Vdrive=10^logVs;
V0=env2.P0.V0;
f0=env2.P0.f0;
Dc=env2.P0.Dc;
b=env2.P0.b;
alpha=env2.P0.alpha;
dTdt_inf=env2.P0.dtaudt;
k=env2.P0.k;

% Get the derived variables.
Psi=env2.Os.Psi(I2);
Theta=exp((Psi-f0)/b)*Dc/V0;
dTdt=dTdt_inf-k*Vdrive;
g1_a=1-(Theta*Vdrive/Dc); % Aging law.
g1_s=(-Theta*Vdrive/Dc).*log(Theta*Vdrive/Dc); % Slip law.

% Filter temporally.
I=(t2>=0.480)&(t2<1.141);
t2=t2(I);
P2=P2(I);
Psi=Psi(I);
Theta=Theta(I);
g1_a=g1_a(I);
g1_s=g1_s(I);

% Get exponential curve parameters.
C=dTdt*Theta./(g1_s*b);
A=P2(1)-C;
B=g1_s*b./(alpha*Theta);
%A=mean(A);
%B=mean(B);
%C=mean(C);
%C=P2(end);

% Predict the exponential curve.
tf=linspace(min(t2),max(t2),50);
Pp=A*exp(B*(tf-min(tf)))+C;

% Fit to an exponential curve.
f=fittype('a-b*exp(-c*x)');
Pf=fit(t2,P2,f,'StartPoint',[[ones(size(t2)), -exp(-t2)]\P2; 1]);

% Plot.
figure(1); clf;
plot(t2,P2,    '-xb'); hold on;
%plot(tf,Pp,     '-r');
plot(tf,Pf(tf), '-r');
xlabel('Time (s)');
ylabel('Change in Pore Pressure, \DeltaP (MPa)');
