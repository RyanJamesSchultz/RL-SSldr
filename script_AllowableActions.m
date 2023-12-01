% Script to show the allowable actions in the phase-space.
% Used to assist in making Figure 2.
clear;

% Define the environment & action experience structure.
env = RL_SSenv();
expBatch=struct('Observation',[],'Action',[],'Reward',[],'NextObservation',[],'IsDone',[]); i=1;

% Actions to get to the nucleation phase (make change in RL_SSenv).
%expBatch(i).Action={[+0.00; +Inf]}; i=i+1;
%expBatch(i).Action={[+0.01;-1.36]}; i=i+1;
%expBatch(i).Action={[+0.05;+3]}; i=i+1; % Test action.

% Actions to get to the co-seismic phase.
expBatch(i).Action={[+0.00; +Inf]}; i=i+1;
expBatch(i).Action={[+0.01;-1.3622]}; i=i+1;

% Actions to get to the immediate post-seismic phase.
%expBatch(i).Action={[+0.00; +Inf]}; i=i+1;

% Actions to get to the later post-seismic phase (make change in RL_SSenv).
%expBatch(i).Action={[-0.05;+3]}; i=i+1; % Test action.

% Actions to get to the inter-seismic phase (make change in RL_SSenv).
%expBatch(i).Action={[+0.00; +Inf]}; i=i+1;
%expBatch(i).Action={[+0.00; +Inf]}; i=i+1;
%expBatch(i).Action={[+0.00; +Inf]}; i=i+1;
%expBatch(i).Action={[+0.00; +Inf]}; i=i+1;
%expBatch(i).Action={[+0.00; +Inf]}; i=i+1;
%expBatch(i).Action={[+0.00; +Inf]}; i=i+1;
%expBatch(i).Action={[+0.05;-3]}; i=i+1; % Test action.

% Apply the actions to the environment.
for i=1:length(expBatch)
    [obs,rew,done,~] = env.step(expBatch(i).Action{1});
end

% Plot.
env.plot();