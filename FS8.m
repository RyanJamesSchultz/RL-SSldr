% Example of an agent overshooting the steady-state transition, but recovering.
% Used to make Figure S8.
clear;

% Get the required variables.
FileName='AlgoRein_v24.mat'; N=62;

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
expBatch2(i).Action={[-0.05;+0.95]}; i=i+1;
expBatch2(i).Action={[+0.05;+0.95]}; i=i+1;
expBatch2(i).Action={[+0.05;+0.95]}; i=i+1;
expBatch2(i).Action={[+0.05;+0.95]}; i=i+1;
expBatch2(i).Action={[+0.05;+0.95]}; i=i+1;

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