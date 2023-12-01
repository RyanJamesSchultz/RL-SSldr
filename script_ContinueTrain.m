% Script to continue training a reinforcement learning agent.
clear;

% Pull in the previously trained agent and environment.
load('initialAgent_p3_05e4.mat'); % Contains the agent & training/stats object.
%trainingStats.TrainingOptions.Plots='training-progress';

% Modify agent noise model for plateau 3b training.
trainingStats.TrainingOptions.MaxEpisodes=4.5e5;
agent.AgentOptions.ExplorationModel.StandardDeviation = [0.0;0.020];
agent.AgentOptions.ExplorationModel.StandardDeviationDecayRate = [0;1e-6];
agent.AgentOptions.ExplorationModel.StandardDeviationMin = [0;0.020];
agent.AgentOptions.TargetPolicySmoothModel.StandardDeviation = [0.0;0.015];
agent.AgentOptions.TargetPolicySmoothModel.StandardDeviationDecayRate = [0;1e-6];
agent.AgentOptions.TargetPolicySmoothModel.StandardDeviationMin = [0;0.015];

% Train again (on noise plateau 3b).
trainingStats = train(agent,SS1env,trainingStats);

% Save again.
SS1env.reset();
save('initialAgent_p3_10e4.mat','agent','trainingStats','SS1env');

% Train for 3c.
trainingStats.TrainingOptions.MaxEpisodes=5.0e5;
trainingStats = train(agent,SS1env,trainingStats);
SS1env.reset();
save('initialAgent_p3_15e4.mat','agent','trainingStats','SS1env');

% Train for 3d.
trainingStats.TrainingOptions.MaxEpisodes=5.5e5;
trainingStats = train(agent,SS1env,trainingStats);
SS1env.reset();
save('initialAgent_p3_20e4.mat','agent','trainingStats','SS1env');

% Train for 3e.
trainingStats.TrainingOptions.MaxEpisodes=6.0e6;
trainingStats = train(agent,SS1env,trainingStats);
SS1env.reset();
save('initialAgent_p3_25e4.mat','agent','trainingStats','SS1env');
