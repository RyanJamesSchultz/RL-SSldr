% Script to continue training a reinforcement learning agent.
clear;

% Pull in the previously trained agent and environment.
load('initialAgent_p3_20e4.mat'); % Contains the agent & training/stats object.
%trainingStats.TrainingOptions.Plots='training-progress';

% Train for 3e.
trainingStats.TrainingOptions.MaxEpisodes=5.6e5;
trainingStats = train(agent,SS1env,trainingStats);
SS1env.reset();
save('initialAgent_p3_21e4.mat','agent','trainingStats','SS1env');

% Train for 3e.
trainingStats.TrainingOptions.MaxEpisodes=5.7e5;
trainingStats = train(agent,SS1env,trainingStats);
SS1env.reset();
save('initialAgent_p3_22e4.mat','agent','trainingStats','SS1env');

% Train for 3e.
trainingStats.TrainingOptions.MaxEpisodes=5.8e5;
trainingStats = train(agent,SS1env,trainingStats);
SS1env.reset();
save('initialAgent_p3_23e4.mat','agent','trainingStats','SS1env');

% Train for 3e.
trainingStats.TrainingOptions.MaxEpisodes=5.9e5;
trainingStats = train(agent,SS1env,trainingStats);
SS1env.reset();
save('initialAgent_p3_24e4.mat','agent','trainingStats','SS1env');

% Train for 3e.
trainingStats.TrainingOptions.MaxEpisodes=6.0e5;
trainingStats = train(agent,SS1env,trainingStats);
SS1env.reset();
save('initialAgent_p3_25e4.mat','agent','trainingStats','SS1env');



