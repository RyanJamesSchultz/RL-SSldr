% Script to explore injection policies around the steady-state boundary.
clear;

% Get the required variables.
%FileName='AlgoRein_v24.mat'; N=62;
FileName='AlgoRein_v44.mat'; N=51;

% Define the environment, load/do the numerical reining steps.
env = RL_SSenv();
load(FileName,'expBatch','logVs');
tic;
for i=1:N
    env.step(expBatch(i).Action{1});
end
toc;

% Define new experience structure.
expBatch2=struct('Observation',[],'Action',[],'Reward',[],'NextObservation',[],'IsDone',[]); i=1;

% Make a batch of additional hand-picked actions.
expBatch2(i).Action={[-0.05;-3.00]}; i=i+1;
%expBatch2(i).Action={[-0.05;+0.63]}; i=i+1;
%expBatch2(i).Action={[-0.05;+0.57]}; i=i+1;
%expBatch2(i).Action={[-0.05;+0.48]}; i=i+1;
%expBatch2(i).Action={[-0.05;+0.38]}; i=i+1;
%expBatch2(i).Action={[+0.50;+0.90]}; i=i+1;
%expBatch2(i).Action={[+1.50;+0.90]}; i=i+1;
%expBatch2(i).Action={[+1.50;-1.00]}; i=i+1;
%expBatch2(i).Action={[+0.30;+3.00]}; i=i+1;
%expBatch2(i).Action={[+0.00;-Inf]}; i=i+1;


%expBatch2(i).Action={[-0.05;-3.00]}; i=i+1;
%expBatch2(i).Action={[+0.50;-2.50]}; i=i+1;

% Run the routine and collect the data.
tic;
for i=1:length(expBatch2)
    expBatch2(i).Observation={env.State()};
    [obs,rew,done,~] = env.step(expBatch2(i).Action{1});
    expBatch2(i).Observation={obs};
    expBatch2(i).Reward=rew;
    expBatch2(i).NextObservation={env.State()};
    expBatch2(i).IsDone=done;
end
toc;

% Plot.
env.plot();