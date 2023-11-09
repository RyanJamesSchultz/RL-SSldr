% Script to continue training a reinforcement learning agent.
clear;

% Pull in the previously trained agent and environment.
load('initialAgent_p3_8e5.mat'); % Contains the agent & training/stats object.
%trainingStats.TrainingOptions.Plots='training-progress';

% Modify agent noise model to transition to plateau 4a training.
trainingStats.TrainingOptions.MaxEpisodes=1.9e6;
agent.AgentOptions.ExplorationModel.StandardDeviation = [0.0;0.015];
agent.AgentOptions.ExplorationModel.StandardDeviationDecayRate = [0;3e-4];
agent.AgentOptions.ExplorationModel.StandardDeviationMin = [0;0.01];
agent.AgentOptions.TargetPolicySmoothModel.StandardDeviation = [0.0;0.01];
agent.AgentOptions.TargetPolicySmoothModel.StandardDeviationDecayRate = [0;3e-4];
agent.AgentOptions.TargetPolicySmoothModel.StandardDeviationMin = [0;0.006];

% Train again (on noise plateau 4a).
trainingStats = train(agent,SS1env,trainingStats);

% Save again.
SS1env.reset();
save('initialAgent_p4_1e5.mat','agent','trainingStats','SS1env');

% Modify agent noise model for plateau 4b training.
trainingStats.TrainingOptions.MaxEpisodes=2.0e6;
agent.AgentOptions.ExplorationModel.StandardDeviation = [0.0;0.01];
agent.AgentOptions.ExplorationModel.StandardDeviationDecayRate = [0;1e-6];
agent.AgentOptions.ExplorationModel.StandardDeviationMin = [0;0.01];
agent.AgentOptions.TargetPolicySmoothModel.StandardDeviation = [0.0;0.006];
agent.AgentOptions.TargetPolicySmoothModel.StandardDeviationDecayRate = [0;1e-6];
agent.AgentOptions.TargetPolicySmoothModel.StandardDeviationMin = [0;0.006];

% Train again (on noise plateau 4b).
trainingStats = train(agent,SS1env,trainingStats);

% Save again.
SS1env.reset();
save('initialAgent_p4_2e5.mat','agent','trainingStats','SS1env');

% Train for 4c.
trainingStats.TrainingOptions.MaxEpisodes=2.1e6;
trainingStats = train(agent,SS1env,trainingStats);
SS1env.reset();
save('initialAgent_p4_3e5.mat','agent','trainingStats','SS1env');

% Train for 4d.
trainingStats.TrainingOptions.MaxEpisodes=2.2e6;
trainingStats = train(agent,SS1env,trainingStats);
SS1env.reset();
save('initialAgent_p4_4e5.mat','agent','trainingStats','SS1env');

% Train for 4e.
trainingStats.TrainingOptions.MaxEpisodes=2.3e6;
trainingStats = train(agent,SS1env,trainingStats);
SS1env.reset();
save('initialAgent_p4_5e5.mat','agent','trainingStats','SS1env');

% Modify agent noise model to transition to plateau 5a training.
trainingStats.TrainingOptions.MaxEpisodes=2.4e6;
agent.AgentOptions.ExplorationModel.StandardDeviation = [0.0;0.01];
agent.AgentOptions.ExplorationModel.StandardDeviationDecayRate = [0;3e-4];
agent.AgentOptions.ExplorationModel.StandardDeviationMin = [0;0.005];
agent.AgentOptions.TargetPolicySmoothModel.StandardDeviation = [0.0;0.006];
agent.AgentOptions.TargetPolicySmoothModel.StandardDeviationDecayRate = [0;3e-4];
agent.AgentOptions.TargetPolicySmoothModel.StandardDeviationMin = [0;0.003];

% Train again (on noise plateau 5a).
trainingStats = train(agent,SS1env,trainingStats);

% Save again.
SS1env.reset();
save('initialAgent_p5_1e5.mat','agent','trainingStats','SS1env');

% Modify agent noise model for plateau 5b training.
trainingStats.TrainingOptions.MaxEpisodes=2.5e6;
agent.AgentOptions.ExplorationModel.StandardDeviation = [0.0;0.005];
agent.AgentOptions.ExplorationModel.StandardDeviationDecayRate = [0;1e-6];
agent.AgentOptions.ExplorationModel.StandardDeviationMin = [0;0.005];
agent.AgentOptions.TargetPolicySmoothModel.StandardDeviation = [0.0;0.003];
agent.AgentOptions.TargetPolicySmoothModel.StandardDeviationDecayRate = [0;1e-6];
agent.AgentOptions.TargetPolicySmoothModel.StandardDeviationMin = [0;0.003];

% Train again (on noise plateau 5b).
trainingStats = train(agent,SS1env,trainingStats);

% Save again.
SS1env.reset();
save('initialAgent_p5_2e5.mat','agent','trainingStats','SS1env');

% Train for 5c.
trainingStats.TrainingOptions.MaxEpisodes=2.6e6;
trainingStats = train(agent,SS1env,trainingStats);
SS1env.reset();
save('initialAgent_p5_3e5.mat','agent','trainingStats','SS1env');

% Train for 5d.
trainingStats.TrainingOptions.MaxEpisodes=2.7e6;
trainingStats = train(agent,SS1env,trainingStats);
SS1env.reset();
save('initialAgent_p5_4e5.mat','agent','trainingStats','SS1env');

% Train for 5e.
trainingStats.TrainingOptions.MaxEpisodes=2.8e6;
trainingStats = train(agent,SS1env,trainingStats);
SS1env.reset();
save('initialAgent_p5_5e5.mat','agent','trainingStats','SS1env');


