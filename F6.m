% Script to check the change in reining stress rate over the nulceation phase.
% Used to make Figure 6.
clear;

% Define the environment & experiences.
env = RL_SSenv();
expBatch=struct('Observation',[],'Action',[],'Reward',[],'NextObservation',[],'IsDone',[]); i=1;

% Playing around with reined slip.
%expBatch(i).Action={[+0.550;+1.00]}; i=i+1;  % Inject right through co-seismic slip.
%expBatch(i).Action={[+0.450;+0.00]}; i=i+1;  % Inject right through co-seismic slip.
expBatch(i).Action={[+0.400;-1.00]}; i=i+1;  % Inject right through co-seismic slip.
%expBatch(i).Action={[+0.336;-2.00]}; i=i+1;  % Inject right through co-seismic slip.

% Run the routine and collect the data.
tic;
for i=1:length(expBatch)
    expBatch(i).Observation={env.State()};
    [obs,rew,done,~] = env.step(expBatch(i).Action{1});
    expBatch(i).Observation={obs};
    expBatch(i).Reward=rew;
    expBatch(i).NextObservation={env.State()};
    expBatch(i).IsDone=done;
end
toc;

% Get the required variables.
V0=env.P0.V0;
f0=env.P0.f0;
Dc=env.P0.Dc;
b=env.P0.b;
alpha=env.P0.alpha;
dTdt_inf=env.P0.dtaudt;
k=env.P0.k;

% Get the indicies for the restricted range of values.
V2=1e-1;
V1=1e-6;
I=(env.Oc.V>=V1)&(env.Oc.V<=V2);

% Get the vectors.
t=env.Oc.t(I)-env.Oc.t(1);
V=env.Oc.V(I);
D=env.Oc.D(I)-env.Oc.D(1);
N=env.Oc.norm(I);
T=env.Oc.tau(I);
Psi=env.Oc.Psi(I);

% Derive some values.
Theta=exp((Psi-f0)/b)*Dc/V0;
dTdt=dTdt_inf-k*V;

% Check for state evolution law.
if(strcmpi(env.F.StateLaw,'aging'))
    g1=1-(Theta.*V/Dc);
elseif(strcmpi(env.F.StateLaw,'slip'))
    g1=(-Theta.*V/Dc).*log(Theta.*V/Dc);
end

% Generate the best guess, based on numerical estimation of normal stressing rate (Eqn S8).
dNdt=(N.*g1.*b)./(alpha*Theta)-(dTdt/alpha);
dPdt=-dNdt; % Returned in the action-space format.

% Get the index of the last feasible reining pressurization rate.
Pmax=10;
i=find(dPdt<=Pmax,1,'last');
t(end)-t(1)
D(i)/Dc

%%% Plot.
% Regular enviroment plots.
env.plot();

% Reining rate vs slip distance.
figure(6); clf;
semilogy(D/Dc,V); hold on;
semilogy(D/Dc,dPdt*1e-5);
xlabel('Normalized slip distance (D/D_c) (-)'); ylabel('Slip velocity (m/s)');

