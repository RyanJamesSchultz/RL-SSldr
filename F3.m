% Script to plot the reined trajectories and injection schemes.
% Used to assist in making Figure 3 (and Figure S5).
% Note that the AlgoRein files may need to be recomputed for different machines.
clear;

% Predefine some variables.
FileName1='AlgoRein_v24.mat'; N1=62;
FileName2='AlgoRein_v44.mat'; N2=51;
FileName3='AlgoRein_rec.mat'; N3=71;

% Define the environment, load/do the numerical reining steps.
env1 = RL_SSenv();
load(FileName1,'expBatch','logVs');
expBatch1=expBatch;
tic;
for i1=1:N1
    env1.step(expBatch1(i1).Action{1});
end
toc;

% Define the environment, load/do the numerical reining steps.
env2 = RL_SSenv();
load(FileName2,'expBatch','logVs');
expBatch2=expBatch;
tic;
for i2=1:N2
    env2.step(expBatch2(i2).Action{1});
end
toc;

% Define the environment, load/do the numerical reining steps.
env3 = RL_SSenv();
load(FileName3,'expBatch','logVs');
expBatch3=expBatch;
tic;
for i3=1:N3
    env3.step(expBatch3(i3).Action{1});
end
toc;

% Define new experience structure.
expBatchN=struct('Observation',[],'Action',[],'Reward',[],'NextObservation',[],'IsDone',[]); iN=1;
expBatchN(iN).Action={[+0.05;-0.00]}; iN=iN+1;
%expBatchN(i).Action={[+0.00;-Inf]}; iN=iN+1;

% Run the routine.
tic;
for iN=1:length(expBatchN)
    env1.step(expBatchN(iN).Action{1});
    env2.step(expBatchN(iN).Action{1});
    env3.step(expBatchN(iN).Action{1});
end
toc;

% Some ploting variables.
I1=(env1.Os.t>env1.O1.t(end));
I2=(env2.Os.t>env2.O1.t(end));
I3=(env3.Os.t>env3.O1.t(end));
t1=env1.Os.t(I1);
t2=env2.Os.t(I2);
t3=env3.Os.t(I3);
i1=find(I1,true,'first');
i2=find(I2,true,'first');
i3=find(I3,true,'first');

% Failure bounds.
Vfail=2e-1;
Vslow=1e-5;

%%

% Plot.
figure(3); clf;

% Phase-space trajectories.
subplot(121);
Vss = logspace(-12,0,100);
fss = fsteadystate(env1,Vss);
semilogx(env1.Os.V(I1),env1.Os.tau(I1)./env1.Os.norm(I1),'-b','DisplayName','\mu'); hold on;
semilogx(env1.Os.V(i1),env1.Os.tau(i1)./env1.Os.norm(i1),'ob','HandleVisibility','off');
semilogx(env2.Os.V(I2),env2.Os.tau(I2)./env2.Os.norm(I2),':b','DisplayName','\mu');
semilogx(env2.Os.V(i2),env2.Os.tau(i2)./env2.Os.norm(i2),'ob','HandleVisibility','off');
semilogx(env3.Os.V(I3),env3.Os.tau(I3)./env3.Os.norm(I3),'--b','DisplayName','\mu');
semilogx(env3.Os.V(i3),env3.Os.tau(i3)./env3.Os.norm(i3),'ob','HandleVisibility','off');
semilogx(Vss,fss,'--k','DisplayName','\mu_{SS}');
semilogx(Vfail*[1 1],ylim(),':k','HandleVisibility','off');
semilogx(Vslow*[1 1],ylim(),':k','HandleVisibility','off');
xlabel('Fault slip velocity (m/s)');
ylabel('Friction coefficient, \mu');
legend('Location','best');
ylim([0.45 0.58]);
xlim([1e-14 1e0]);
grid on;

% Pressure curves.
P1=(env1.P1.N-env1.Os.norm(I1))-env1.P1.P(1);
P2=(env2.P1.N-env2.Os.norm(I2))-env2.P1.P(1);
P3=(env3.P1.N-env3.Os.norm(I3))-env3.P1.P(1);

% Pumping pressure curves.
subplot(122);
plot(t1-t1(1),P1,'-b'); hold on;
plot(t2-t2(1),P2,':b');
plot(t3-t3(1),P3,'--b');
xlabel('Time (s)');
ylabel('Change in Fault Pore Pressure, \DeltaP (MPa)');

% Some extra plots.
figure(4); clf;
semilogy(env2.Oc.D/env2.P0.Dc,env2.Oc.V);
xlabel('normalized slip (-)'); ylabel('slip velocity (m/s)');
figure(5); clf;
plot(env2.Oc.D/env2.P0.Dc,env2.Oc.norm);
xlabel('normalized slip (-)'); ylabel('Normal stress (MPa)');




% Subroutine.
function fss = fsteadystate(this,V)
    fss = this.P0.f0+(this.P0.a-this.P0.b)*log(V/this.P0.V0);
end