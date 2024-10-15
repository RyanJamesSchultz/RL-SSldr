% Script to demonstrate steady-slip, immediately following co-seismic slip.
% Used to make Figure 4.
clear;

% Define some paramteres.
FileName='AlgoRein_v44.mat'; % Reined-slip instructions.
N=51;

% Define the environment, load/do the numerical reining steps, and get to the end-point.
env = RL_SSenv();
load(FileName,'expBatch','logVs');
expBatch(N+1).Action={[+0.05;+0.00]}; % Trigger the small stick-slip event.
env.append(expBatch(1:N+1));

% Get the required variables.
Vdrive=10^logVs;
V0=env.P0.V0;
f0=env.P0.f0;
Dc=env.P0.Dc;
b=env.P0.b;
alpha=env.P0.alpha;
dTdt_inf=env.P0.dtaudt;
k=env.P0.k;

% Define new action-history structure.
expBatch2=struct('Observation',[],'Action',[],'Reward',[],'NextObservation',[],'IsDone',[]); i=1;

% Make a batch of additional hand-picked actions.
expBatch2(i).Action={[ +1.00;+0.00]}; i=i+1;
expBatch2(i).Action={[ +2.00;+0.20]}; i=i+1;
expBatch2(i).Action={[ +2.00;+0.40]}; i=i+1;
expBatch2(i).Action={[ +3.00;+0.60]}; i=i+1;
expBatch2(i).Action={[ +4.00;+0.80]}; i=i+1;
expBatch2(i).Action={[ +6.00;+1.00]}; i=i+1;
expBatch2(i).Action={[+20.00;+1.20]}; i=i+1;
%expBatch2(i).Action={[+40.00;+1.40]}; i=i+1;
%expBatch2(i).Action={[+100.00;+1.60]}; i=i+1;

% Run the routine and collect the data.
V_n=zeros(size(expBatch2)); dNdt_n=V_n; dTdt_n=V_n;
for i=1:length(expBatch2)
    i
    env.reset();
    expBatch2(i).Observation={env.State()};
    [obs,rew,done,~] = env.step(expBatch2(i).Action{1});
    expBatch2(i).Observation={obs};
    expBatch2(i).Reward=rew;
    expBatch2(i).NextObservation={env.State()};
    expBatch2(i).IsDone=done;
    V_n(i)=env.Oc.V(end);
    action=expBatch2(i).Action{1};
    dNdt_n(i)=10^action(2);
    dTdt_n(i)=(env.Oc.tau(end)-env.Oc.tau(end-1))/(env.Oc.t(end)-env.Oc.t(end-1));
end

% Get the derived variables.
Psi=env.Oc.Psi(end);
Theta=exp((Psi-f0)/b)*Dc/V0;
dTdt=dTdt_inf-k*Vdrive;
g1_a=1-(Theta*Vdrive/Dc); % Aging law.
g1_s=(-Theta*Vdrive/Dc)*log(Theta*Vdrive/Dc); % Slip law.

% Get the analytical equation coefficients.
g1=g1_s;
a1=(dTdt*Theta)/(g1*b);
b2=(g1*b)/(Theta*alpha);
c3=1;

% Plot the spring-slider environment details.
env.plot();

% Get the analytical expressions, under the no-healing approximation.
V_a=10.^(-12:0.1:1);
dTdt_a_lin=dTdt_inf-k*V_a;
dNdt_a_lin=-dTdt_a_lin/alpha;
%dNdt_a_exp=a1+exp(b2*t)*c3;

% Plot the analytical/numerical results.
figure(4); clf;
loglog(V_a,abs(dNdt_a_lin),'-b','DisplayName','| d\sigma/dt | analytical (no-healing)'); hold on;
loglog(V_n,abs(dNdt_n),'ob','DisplayName','| d\sigma/dt | numerical');
loglog(V_a,abs(dTdt_a_lin),'-r','DisplayName','| d\tau/dt | analytical (no-healing)');
loglog(V_n,abs(dTdt_n),'or','DisplayName','| d\tau/dt | numerical');
xlabel('Slip velocity (m/s)');
ylabel('Fault stressing rate (MPa/s)');
legend('Location','northwest');
ylim(10.^[-3 +3]);
xlim([1e-3 1e0]);
