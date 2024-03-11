% Script to plot the reining stress rate over the entire earthquake cycle.
% Used to makes Figures S1-S3.
%%% NOTE that you have to temporarily change the prime_fault time duration (i.e., to 43 years) in RL_SSenv to go through multiple cycles.
clear;

% Predefine the window of a full seismic cycle.
t1=10.7055;
t2=24.4045;

% Within that window, define the times bounding each seismic phase.
Tpi=00.0000; % Velocity is at a minimum.
Tin=12.8981; % State is at a maximum.
Tns=12.996688585749; % Roughly rounding the corner.
Tsp=12.996688585764; % Velocity is at a maximum and state at minimum.

% Window limits.
MUlim=[0.45 0.58];
Vlim=[1e-14 1e0];

% Create the spring slider environment.
SS1env = RL_SSenv();

% Manually prescribe the first N moves, which will trigger an earthquake slip cycle.
%expBatch=struct('Observation',[],'Action',[],'Reward',[],'NextObservation',[],'IsDone',[]); i=1;
%expBatch(i).Action={[+0.48;+1.000]}; i=i+1;
%expBatch(i).Action={[+0.00;  -Inf]}; i=i+1;
%expBatch(i).Action={[+0.00;  -Inf]}; i=i+1;
%expBatch(i).Action={[+0.00;  -Inf]}; i=i+1;
%expBatch(i).Action={[+0.00;  -Inf]}; i=i+1;
%expBatch(i).Action={[+0.00;  -Inf]}; i=i+1;
%expBatch(i).Action={[+0.00;  -Inf]}; i=i+1;

% Loop over all of the actions.
%for i=1:length(expBatch)
    
    % Do the actions.
    %action=expBatch(i).Action{1};
    %SS1env.step(action);
%end



% Plot.
%SS1env.plot();

% Predefine some values.
oneyear = 60*60*24*365.25; % Seconds in a year.
t=SS1env.Os.t/oneyear;
I=(t>t1)&(t<t2);
I=find(I);
t=t(I);
t=t-t(1);
J=1:length(t);

% Find the indicies for the seismic phase boundaries.
[~,i_pi]=min(abs(Tpi-t));
[~,i_in]=min(abs(Tin-t));
[~,i_ns]=min(abs(Tns-t));
[~,i_sp]=min(abs(Tsp-t));

% Failure bounds.
Vfail=2e-1;
Vslow=1e-5;

% Get the required variables.
V0=SS1env.P0.V0;
f0=SS1env.P0.f0;
Dc=SS1env.P0.Dc;
b=SS1env.P0.b;
alpha=SS1env.P0.alpha;
dTdt_inf=SS1env.P0.dtaudt;
k=SS1env.P0.k;

% Get some more variables.
V=SS1env.Os.V;
N=SS1env.Os.norm;
Psi=SS1env.Os.Psi;
Theta=exp((Psi-f0)/b)*Dc/V0;
dTdt=dTdt_inf-k*V;

% Check for state evolution law.
if(strcmpi(SS1env.F.StateLaw,'aging'))
    g1=1-(Theta.*V/Dc);
elseif(strcmpi(SS1env.F.StateLaw,'slip'))
    g1=(-Theta.*V/Dc).*log(Theta.*V/Dc);
end

% Generate the best guess, based on numerical estimation of normal stressing rate (Eqn S1.8).
dNdt=(N.*g1.*b)./(alpha*Theta)-(dTdt/alpha);
dPdt=-dNdt;

% Plot.
figure(1),clf

ax1=subplot(3,1,1);
semilogy(t,SS1env.Os.V(I),'-b'); hold on;
xlim([min(t) max(t)]); ylim(Vlim);
semilogy(t(i_pi),SS1env.Os.V(I(i_pi)),'xb');
semilogy(t(i_in),SS1env.Os.V(I(i_in)),'xb');
semilogy(t(i_ns),SS1env.Os.V(I(i_ns)),'xb');
semilogy(t(i_sp),SS1env.Os.V(I(i_sp)),'xb');
semilogy(xlim(),Vfail*[1 1],':k');
semilogy(xlim(),Vslow*[1 1],':k');
xlabel('Time (years)');
ylabel('Slip velocity (m/s)');

%ax2=subplot(5,1,2);
%plot(t, SS1env.Os.D(I)*100);
%xlabel('Time (years)');
%ylabel('Slip displacement (cm)');

%ax3=subplot(5,1,3);
%plot(t,SS1env.Os.tau(I), 'DisplayName','Shear Stress'); hold on;
%plot(t,SS1env.Os.norm(I),'DisplayName','Normal Stress');
%plot(xlim(),SS1env.Nc*[1 1],'--k','DisplayName','Critical Normal Stress');
%xlabel('Time (years)');
%ylabel('Fault stress (MPa)');
%legend('Location','southwest');

ax2=subplot(3,1,2);
%Theta=exp((SS1env.O1.Psi-SS1env.P0.f0)/SS1env.P0.b)*SS1env.P0.Dc/SS1env.P0.V0;
Psi=SS1env.Os.Psi(I);
plot(t,Psi,'-b'); hold on;
plot(t(i_pi),Psi(i_pi),'xb');
plot(t(i_in),Psi(i_in),'xb');
plot(t(i_ns),Psi(i_ns),'xb');
plot(t(i_sp),Psi(i_sp),'xb');
xlabel('Time (years)');
ylabel('Fault state \Psi (-)');
xlim([min(t) max(t)]); ylim([0.40 0.58]);

Ip=(dPdt(I)>0);
ax3=subplot(3,1,3);
semilogy(t,abs(dPdt(I)),'-b'); hold on;
plot(t(i_pi),abs(dPdt(I(i_pi))),'xb');
plot(t(i_in),abs(dPdt(I(i_in))),'xb');
plot(t(i_ns),abs(dPdt(I(i_ns))),'xb');
plot(t(i_sp),abs(dPdt(I(i_sp))),'xb');
plot(t(Ip),ones(size(t(Ip))),'xr');
plot(t(~Ip),ones(size(t(~Ip))),'or');
xlabel('Time (years)');
ylabel('Reining Pressure Rate (MPa/s)');
xlim([min(t) max(t)]);
linkaxes([ax1 ax2 ax3 ],'x');

figure(2); clf;
Vss = logspace(-14,0,100);
fss = fsteadystate(SS1env,Vss);
fsb = fstablebound(SS1env,Vss);
semilogx(SS1env.Os.V(I),SS1env.Os.tau(I)./SS1env.Os.norm(I),'-b','DisplayName','f'); hold on;
%semilogx(SS1env.Os.V(I(1)),SS1env.Os.tau(I(1))./SS1env.Os.norm(I(1)),'ob','HandleVisibility','off');
semilogx(SS1env.Os.V(I(i_pi)),SS1env.Os.tau(I(i_pi))./SS1env.Os.norm(I(i_pi)),'xb','HandleVisibility','off');
semilogx(SS1env.Os.V(I(i_in)),SS1env.Os.tau(I(i_in))./SS1env.Os.norm(I(i_in)),'xb','HandleVisibility','off');
semilogx(SS1env.Os.V(I(i_ns)),SS1env.Os.tau(I(i_ns))./SS1env.Os.norm(I(i_ns)),'xb','HandleVisibility','off');
semilogx(SS1env.Os.V(I(i_sp)),SS1env.Os.tau(I(i_sp))./SS1env.Os.norm(I(i_sp)),'xb','HandleVisibility','off');
semilogx(Vss,fss,'--k','DisplayName','fss');
semilogx(Vss,fsb,'-r','DisplayName','fsb');
semilogx(Vfail*[1 1],ylim(),':k','HandleVisibility','off');
semilogx(Vslow*[1 1],ylim(),':k','HandleVisibility','off');
xlabel('Fault slip velocity (m/s)');
ylabel('Friction coefficient');
legend('Location','southwest');
ylim(MUlim);
grid on;

