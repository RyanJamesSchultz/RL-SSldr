% A script that will run the trained agent on the environment, trying to test for robustness to parameter changes.
% Note that RL_SSenv.m must be changed to perturb the spring-slider parameters.
% Used to inform Text S3.
clear;

% Load in the agent and then overwrite the environment.
load('/Users/rschultz/Desktop/RL-SSldr/codes/MatLab/TrainedAgents/Try20/Agent_p3_25e4.mat');
SS1env = RL_SSenv();

% Manually prescribe the first move, which will trigger earthquake slip nucleation.
expBatch=struct('Observation',[],'Action',[],'Reward',[],'NextObservation',[],'IsDone',[]); i=1;
expBatch(i).Action={[+0.480;+1.000]}; i=i+1;
SS1env.append(expBatch);
SS1env.reset();

% Step over the agent's choices, paused at each step for user input.
while(true)
    obs = SS1env.State;
    act = cell2mat(getAction(agent,obs));
    [act(1) act(2)]
    %act(2)=act(2)+normrnd(0,0.015,[1 1]); % Sprinkle in some noise, for fun.
    SS1env.State
    SS1env.step(act);
    
    SS1env.plot();
    pause;
end