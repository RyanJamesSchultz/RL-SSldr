% A script that will run the trained agent on the environment.
clear;

% Load environment & agent.
load('Agent_1e6.mat');
SS1env.reset();

% Step over the agent's choices, paused at each step for user input.
while(true)
    obs = SS1env.State;
    act = cell2mat(getAction(agent,obs));
    [act(1) act(2)]
    SS1env.State
    SS1env.step(act);
    
    SS1env.plot();
    pause;
end