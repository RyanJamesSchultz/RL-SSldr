% Script to plot the reining stress rate over the entire earthquake cycle.
% Used to makes Figures 2, S1, & S2.
%%% NOTE that you have to temporarily change the prime_fault time duration (i.e., to 43 years) in RL_SSenv to go through multiple cycles.
%%% NOTE also that you'll have to change the S0 tol to 1e-6 to produce nice looking reining pressurization rates during the immediately post-seismic phase.
clear;

% Predefine the window of a full seismic cycle.
t1=10.7055;
t2=24.4045;

% Window limits.
MUlim=[0.45 0.58];
Vlim=[1e-14 1e0];

% Create the spring slider environment.
SS1env = RL_SSenv();

% Predefine some values.
oneyear = 60*60*24*365.25; % Seconds in a year.
t=SS1env.Os.t/oneyear;
I=(t>t1)&(t<t2);
I=find(I);
t=t-t(I(1));

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
D=SS1env.Os.V;
Tau=SS1env.Os.tau;
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

% Generate the best guess, based on numerical estimation of normal stressing rate (Eqn 8).
dNdt=(N.*g1.*b)./(alpha*Theta)-(dTdt/alpha);
dPdt=-dNdt;

% Find the indicies for the seismic phase boundaries.
[~,i_pi]=min(V(I));      i_pi=i_pi+I(1)-1;  % Velocity is at a minimum.
[~,i_in]=max(Theta(I));  i_in=i_in+I(1)-1;  % State is at a maximum.
[~,i_sp]=max(V(I));      i_sp=i_sp+I(1)-1;  % Velocity is at a maximum (and state at minimum).
[~,i_ns]=min(abs(V(I(1):i_sp)-6e-3));       % Roughly rounding the corner.
i_ns=i_ns+I(1)-1;

% Define times showing just the nucleation into post-seismic phases.
t1z=t(i_ns)-0.4/oneyear;
t2z=t(i_sp)+0.7/oneyear;

% Cut for the zoom-in plot.
Iz=(t>t1z)&(t<t2z);
Iz=find(Iz);




%%% Plot.

% The variables over the full seismic cycle.
figure(52),clf

% V vs t.
ax1=subplot(3,1,1);
semilogy(t(I),V(I),'-b'); hold on;
xlim([min(t(I)) max(t(I))]); ylim(Vlim);
semilogy(t(i_pi),V(i_pi),'xb');
semilogy(t(i_in),V(i_in),'xb');
semilogy(t(i_ns),V(i_ns),'xb');
semilogy(t(i_sp),V(i_sp),'xb');
semilogy(xlim(),Vfail*[1 1],':k');
semilogy(xlim(),Vslow*[1 1],':k');
xlabel('Time (years)');
ylabel('Slip velocity, V (m/s)');

%ax2=subplot(5,1,2);
%plot(t(I), D(I)*100);
%xlabel('Time (years)');
%ylabel('Slip displacement (cm)');

%ax3=subplot(5,1,3);
%plot(t(I),Tau(I), 'DisplayName','Shear Stress'); hold on;
%plot(t(I),N(I),'DisplayName','Normal Stress');
%plot(xlim(),SS1env.Nc*[1 1],'--k','DisplayName','Critical Normal Stress');
%xlabel('Time (years)');
%ylabel('Fault stress (MPa)');
%legend('Location','southwest');

% State vs t.
ax2=subplot(3,1,2);
plot(t(I),Psi(I),'-b'); hold on;
plot(t(i_pi),Psi(i_pi),'xb');
plot(t(i_in),Psi(i_in),'xb');
plot(t(i_ns),Psi(i_ns),'xb');
plot(t(i_sp),Psi(i_sp),'xb');
xlabel('Time (years)');
ylabel('Fault state, \Psi (-)');
xlim([min(t(I)) max(t(I))]); ylim([0.40 0.58]);

% Reining pressurization rate vs t.
Ip=(dPdt>0);
ax3=subplot(3,1,3);
semilogy(t(I),abs(dPdt(I)),'-b'); hold on;
plot(t(i_pi),abs(dPdt(i_pi)),'xb');
plot(t(i_in),abs(dPdt(i_in)),'xb');
plot(t(i_ns),abs(dPdt(i_ns)),'xb');
plot(t(i_sp),abs(dPdt(i_sp)),'xb');
plot(t(Ip),ones(size(t(Ip))),'xr');
plot(t(~Ip),ones(size(t(~Ip))),'or');
xlabel('Time (years)');
ylabel('Reining Pressure Rate (MPa/s)');
xlim([min(t(I)) max(t(I))]);
linkaxes([ax1 ax2 ax3 ],'x');


% The variables over the nucleation and co-seismic phases.
figure(2),clf
tz=(t-t(Iz(1)))*oneyear;
%tz=t;

% V vs t.
ax1=subplot(3,1,1);
semilogy(tz(Iz),V(Iz),'-b'); hold on;
xlim([min(tz(Iz)) max(tz(Iz))]); ylim([1e-7 max(Vlim)]);
semilogy(tz(i_pi),V(i_pi),'xb');
semilogy(tz(i_in),V(i_in),'xb');
semilogy(tz(i_ns),V(i_ns),'xb');
semilogy(tz(i_sp),V(i_sp),'xb');
semilogy(xlim(),Vfail*[1 1],':k');
semilogy(xlim(),Vslow*[1 1],':k');
xlabel('Time (seconds)');
ylabel('Slip velocity, V (m/s)');

% State vs t.
ax2=subplot(3,1,2);
plot(tz(Iz),Psi(Iz),'-b'); hold on;
plot(tz(i_pi),Psi(i_pi),'xb');
plot(tz(i_in),Psi(i_in),'xb');
plot(tz(i_ns),Psi(i_ns),'xb');
plot(tz(i_sp),Psi(i_sp),'xb');
xlabel('Time (seconds)');
ylabel('Fault state, \Psi (-)');
xlim([min(tz(Iz)) max(tz(Iz))]); ylim([0.40 0.58]);

% Reining pressurization rate vs t.
Ip=(dPdt>0);
ax3=subplot(3,1,3);
semilogy(tz(Iz),abs(dPdt(Iz)),'-b'); hold on;
plot(tz(i_pi),abs(dPdt(i_pi)),'xb');
plot(tz(i_in),abs(dPdt(i_in)),'xb');
plot(tz(i_ns),abs(dPdt(i_ns)),'xb');
plot(tz(i_sp),abs(dPdt(i_sp)),'xb');
plot(tz(Ip),ones(size(tz(Ip))),'xr');
plot(tz(~Ip),ones(size(tz(~Ip))),'or');
xlabel('Time (seconds)');
ylabel('Reining Pressure Rate (MPa/s)');
xlim([min(tz(Iz)) max(tz(Iz))]);
linkaxes([ax1 ax2 ax3 ],'x');


% The seismic cycle for the spring-slider.
figure(51); clf;
Vss = logspace(-14,0,100);
fss = fsteadystate(SS1env,Vss);
%fsb = fstablebound(SS1env,Vss);
semilogx(V(I),Tau(I)./N(I),'-b','DisplayName','\mu'); hold on;
%semilogx(SS1env.Os.V(I(1)),SS1env.Os.tau(I(1))./SS1env.Os.norm(I(1)),'ob','HandleVisibility','off');
semilogx(V(i_pi),Tau(i_pi)./N(i_pi),'xb','HandleVisibility','off');
semilogx(V(i_in),Tau(i_in)./N(i_in),'xb','HandleVisibility','off');
semilogx(V(i_ns),Tau(i_ns)./N(i_ns),'xb','HandleVisibility','off');
semilogx(V(i_sp),Tau(i_sp)./N(i_sp),'xb','HandleVisibility','off');
semilogx(Vss,fss,'--k','DisplayName','\mu_{ss}');
%semilogx(Vss,fsb,'-r','DisplayName','\mu_{sb}');
semilogx(Vfail*[1 1],ylim(),':k','HandleVisibility','off');
semilogx(Vslow*[1 1],ylim(),':k','HandleVisibility','off');
xlabel('Fault slip velocity, V (m/s)');
ylabel('Friction coefficient, \mu');
legend('Location','southwest');
ylim(MUlim);
grid on;

