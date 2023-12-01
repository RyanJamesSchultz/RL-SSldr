% A script to manually play the spring-slider game.
clear;

% Define the environment & experiences.
env = RL_SSenv();
expBatch=struct('Observation',[],'Action',[],'Reward',[],'NextObservation',[],'IsDone',[]); i=1;

% Playing around with reined slip.
expBatch(i).Action={[+0.480;+1.00]}; i=i+1;  % Trigger.
expBatch(i).Action={[-0.050;+0.90]}; i=i+1;  % Undershoot reined slip.
expBatch(i).Action={[-0.050;+1.30]}; i=i+1;  % Overshoot reined slip.

% Playing around with the end-point goal.
%expBatch(i).Action={[+0.480;1.00]}; i=i+1;  % Trigger.
%expBatch(i).Action={[+0.490;0.00]}; i=i+1;  % Steady-state injection driven slip.

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

% Plot.
env.plot();



