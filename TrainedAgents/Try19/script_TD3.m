% Script that trains a reinforcement learning agent to rein-in a spring-slider fault.
clear;




%%% Create the environment.
% Create the spring slider environment.
SS1env = RL_SSenv();
obsInfo = getObservationInfo(SS1env);
actInfo = getActionInfo(SS1env);

% Manually prescribe the first move, which will trigger earthquake slip nucleation.
expBatch=struct('Observation',[],'Action',[],'Reward',[],'NextObservation',[],'IsDone',[]); i=1;
expBatch(i).Action={[+0.480;+1.000]}; i=i+1;
SS1env.append(expBatch);
SS1env.reset();

% Get the scaling limits for input actions.
scale=(actInfo.UpperLimit-actInfo.LowerLimit)/2;
bias=(actInfo.UpperLimit+actInfo.LowerLimit)/2;
% dP:     -3  to +3   MPa.
% dP/dt:  -10 to +10  log10[MPa/s].

% Overloading the actor's scaling layer to always output the same dP step.
scale(1)=0.0; bias(1)=-0.05;

% Further overloading the actor's scaling layer to restrict dP/dt choices [-1.5 to +1.5].
scale(2)=1.5; bias(2)=0.0;




%%% Create the Agent.
% Number of neurons (network width).
L = 256;

% Make the critic.
% Main path.
mainPath = [ ...
    featureInputLayer(prod(obsInfo.Dimension),'Name','ObsInputLayer'),...
    fullyConnectedLayer(L,'Name','FC_O1'),...
    reluLayer('Name','ReLu_O1'),...
    fullyConnectedLayer(L/2,'Name','ObsMergeLayer'),...
    additionLayer(2,'Name','MergedLayer'),...
    reluLayer('Name','ReLu_M1'),...
    fullyConnectedLayer(L/2,'Name','FC_M2'),...
    reluLayer('Name','ReLu_M2'),...
    fullyConnectedLayer(L/2,'Name','FC_M3'),...
    reluLayer('Name','ReLu_M3'),...
    fullyConnectedLayer(1,'Name','QValueOutput')
    ];

% Action path.
actionPath = [ ...
    featureInputLayer(prod(actInfo.Dimension),'Name','ActionInputLayer'),...
    fullyConnectedLayer(L,'Name','FC_A1'),...
    reluLayer('Name','ReLu_A1'),...
    fullyConnectedLayer(L/2,'Name','ActionMergeLayer'),...
    ];

% Assemble paths.
criticNet = layerGraph(mainPath);
criticNet = addLayers(criticNet,actionPath);    
criticNet = connectLayers(criticNet,'ActionMergeLayer','MergedLayer/in2');

% Convert to deep learning network object (and display).
criticNet = dlnetwork(criticNet, Initialize=false);
%figure(1); clf;
%plot(criticNet);
%title('Critic-Net');
%summary(criticNet);

% Create the critics using the specified network and the environment action and observation specifications. 
critic1 = rlQValueFunction(initialize(criticNet),obsInfo, actInfo,'ObservationInputNames','ObsInputLayer','ActionInputNames','ActionInputLayer');
critic2 = rlQValueFunction(initialize(criticNet),obsInfo, actInfo,'ObservationInputNames','ObsInputLayer','ActionInputNames','ActionInputLayer');

% Make the actor.
% Start with a deep network.
actorNet = [
    featureInputLayer(prod(obsInfo.Dimension),'Name','ObsInputLayer')
    fullyConnectedLayer(L,'Name','FC_A1')
    reluLayer('Name','ReLu_A1')
    fullyConnectedLayer(L/2,'Name','FC_A2')
    reluLayer('Name','ReLu_A2')
    fullyConnectedLayer(L/2,'Name','FC_A3')
    reluLayer('Name','ReLu_A3')
    fullyConnectedLayer(prod(actInfo.Dimension),'Name','FC_A4')
    tanhLayer('Name','Tanh_A5')
    scalingLayer('Scale',scale,'Bias',bias,'Name','ActorOutputLayer') 
    ];

% Convert to deep learning network object (and display).
actorNet = dlnetwork(actorNet);
%figure(2); clf;
%plot(actorNet);
%title('Actor-Net');
%summary(actorNet);

% Construct the actor similarly to the critic.
actor = rlContinuousDeterministicActor(actorNet,obsInfo,actInfo);

% Specify training options for the critic and the actor using rlOptimizerOptions.
criticOptions = rlOptimizerOptions('LearnRate',3e-4,'GradientThreshold',1,'L2RegularizationFactor',1e-4);
actorOptions  = rlOptimizerOptions('LearnRate',3e-5,'GradientThreshold',1,'L2RegularizationFactor',1e-4);

% Update the actor/critic using GPU resources.
%criticOptions.UseDevice='gpu';
%actorOptions.UseDevice='gpu';

% Specify the TD3 agent options using rlTD3AgentOptions, include the options for the actor and the critic.
agentOptions = rlTD3AgentOptions('SampleTime',1,...
    'ActorOptimizerOptions',actorOptions,...
    'CriticOptimizerOptions',criticOptions,...
    'ExperienceBufferLength',5e5,...
    'MiniBatchSize',1024,...
    'NumStepsToLookAhead',1,...
    'TargetSmoothFactor',0.2,...
    'TargetUpdateFrequency',128,...
    'DiscountFactor',0.50,...
    'ResetExperienceBufferBeforeTraining',false);
agentOptions.ExplorationModel.StandardDeviation = [0.0;0.30];
agentOptions.ExplorationModel.StandardDeviationDecayRate = [0;1e-6];
agentOptions.ExplorationModel.StandardDeviationMin = [0;0.30];
agentOptions.TargetPolicySmoothModel.StandardDeviation = [0.0;0.15];
agentOptions.TargetPolicySmoothModel.StandardDeviationDecayRate = [0;1e-6];
agentOptions.TargetPolicySmoothModel.StandardDeviationMin = [0;0.15];

% Create the TD3 agent using the actor, critic, and agent options.
agent = rlTD3Agent(actor,[critic1,critic2],agentOptions);




%%% Ways to learn faster?
% Use a prioritized replay buffer.
%agent.ExperienceBuffer = rlPrioritizedReplayMemory(obsInfo,actInfo);

% Add a batch of 'good' experiences to the replay buffer.
%load('AlgoRein_v24.mat','expBatch');
%expBatch=expBatch(1:62);
%expBatch(1)=[];
%append(agent.ExperienceBuffer,expBatch);

% Add another batch of 'good' experiences to the buffer.
%load('AlgoRein_v44.mat','expBatch');
%expBatch=expBatch(1:51);
%expBatch(1)=[];
%append(agent.ExperienceBuffer,expBatch);




%%% Train the agent.
% Specify the training options. 
maxepisodes = 2e4;
maxsteps = 100;
PlotFlag='none';
trainingOpts = rlTrainingOptions('MaxEpisodes',maxepisodes,...
    'MaxStepsPerEpisode',maxsteps,...
    'Verbose',false,...
    'Plots',PlotFlag,...
    'StopTrainingCriteria','AverageReward',...
    'ScoreAveragingWindowLength',300,...
    'StopTrainingValue',200,...
    'UseParallel',true);
%trainingOpts.ParallelizationOptions.Mode = 'async';

% Train the agent (explore noise plateau 1).
trainingStats = train(agent,SS1env,trainingOpts);

% Save the agent.
SS1env.reset();
save('initialAgent_p1.mat','agent','trainingStats','SS1env');

% Modify agent noise model for plateau 2a training.
trainingStats.TrainingOptions.MaxEpisodes=1e5;
trainingStats.TrainingOptions.ScoreAveragingWindowLength=1e3;
agent.AgentOptions.ExplorationModel.StandardDeviation = [0.0;0.30];
agent.AgentOptions.ExplorationModel.StandardDeviationDecayRate = [0;1e-1];
agent.AgentOptions.ExplorationModel.StandardDeviationMin = [0;0.03];
agent.AgentOptions.TargetPolicySmoothModel.StandardDeviation = [0.0;0.15];
agent.AgentOptions.TargetPolicySmoothModel.StandardDeviationDecayRate = [0;1e-1];
agent.AgentOptions.TargetPolicySmoothModel.StandardDeviationMin = [0;0.02];

% Train again (on noise plateau 2a).
trainingStats = train(agent,SS1env,trainingStats);

% Save again.
SS1env.reset();
save('initialAgent_p2_1e5.mat','agent','trainingStats','SS1env');

% Modify agent noise model for plateau 2b training.
trainingStats.TrainingOptions.MaxEpisodes=2e5;
agent.AgentOptions.ExplorationModel.StandardDeviation = [0.0;0.03];
agent.AgentOptions.ExplorationModel.StandardDeviationDecayRate = [0;1e-6];
agent.AgentOptions.ExplorationModel.StandardDeviationMin = [0;0.03];
agent.AgentOptions.TargetPolicySmoothModel.StandardDeviation = [0.0;0.02];
agent.AgentOptions.TargetPolicySmoothModel.StandardDeviationDecayRate = [0;1e-6];
agent.AgentOptions.TargetPolicySmoothModel.StandardDeviationMin = [0;0.02];

% Train again (on noise plateau 2b).
trainingStats = train(agent,SS1env,trainingStats);

% Save again.
SS1env.reset();
save('initialAgent_p2_2e5.mat','agent','trainingStats','SS1env');

% Train for 2c.
trainingStats.TrainingOptions.MaxEpisodes=3e5;
trainingStats = train(agent,SS1env,trainingStats);
SS1env.reset();
save('initialAgent_p2_3e5.mat','agent','trainingStats','SS1env');

% Train for 2d.
trainingStats.TrainingOptions.MaxEpisodes=4e5;
trainingStats = train(agent,SS1env,trainingStats);
SS1env.reset();
save('initialAgent_p2_4e5.mat','agent','trainingStats','SS1env');

% Train for 2e.
trainingStats.TrainingOptions.MaxEpisodes=5e5;
trainingStats = train(agent,SS1env,trainingStats);
SS1env.reset();
save('initialAgent_p2_5e5.mat','agent','trainingStats','SS1env');

% Modify agent noise model to transition to plateau 3a training.
trainingStats.TrainingOptions.MaxEpisodes=6e5;
agent.AgentOptions.ExplorationModel.StandardDeviation = [0.0;0.030];
agent.AgentOptions.ExplorationModel.StandardDeviationDecayRate = [0;3e-4];
agent.AgentOptions.ExplorationModel.StandardDeviationMin = [0;0.015];
agent.AgentOptions.TargetPolicySmoothModel.StandardDeviation = [0.0;0.020];
agent.AgentOptions.TargetPolicySmoothModel.StandardDeviationDecayRate = [0;3e-4];
agent.AgentOptions.TargetPolicySmoothModel.StandardDeviationMin = [0;0.010];

% Train again (on noise plateau 3a).
trainingStats = train(agent,SS1env,trainingStats);

% Save again.
SS1env.reset();
save('initialAgent_p3_1e5.mat','agent','trainingStats','SS1env');

% Modify agent noise model for plateau 3b training.
trainingStats.TrainingOptions.MaxEpisodes=7e5;
agent.AgentOptions.ExplorationModel.StandardDeviation = [0.0;0.015];
agent.AgentOptions.ExplorationModel.StandardDeviationDecayRate = [0;1e-6];
agent.AgentOptions.ExplorationModel.StandardDeviationMin = [0;0.015];
agent.AgentOptions.TargetPolicySmoothModel.StandardDeviation = [0.0;0.010];
agent.AgentOptions.TargetPolicySmoothModel.StandardDeviationDecayRate = [0;1e-6];
agent.AgentOptions.TargetPolicySmoothModel.StandardDeviationMin = [0;0.010];

% Train again (on noise plateau 3b).
trainingStats = train(agent,SS1env,trainingStats);

% Save again.
SS1env.reset();
save('initialAgent_p3_2e5.mat','agent','trainingStats','SS1env');

% Train for 3c.
trainingStats.TrainingOptions.MaxEpisodes=8e5;
trainingStats = train(agent,SS1env,trainingStats);
SS1env.reset();
save('initialAgent_p3_3e5.mat','agent','trainingStats','SS1env');

% Train for 3d.
trainingStats.TrainingOptions.MaxEpisodes=9e5;
trainingStats = train(agent,SS1env,trainingStats);
SS1env.reset();
save('initialAgent_p3_4e5.mat','agent','trainingStats','SS1env');

% Train for 3e.
trainingStats.TrainingOptions.MaxEpisodes=1e6;
trainingStats = train(agent,SS1env,trainingStats);
SS1env.reset();
save('initialAgent_p3_5e5.mat','agent','trainingStats','SS1env');

% Modify agent noise model to transition to plateau 4a training.
trainingStats.TrainingOptions.MaxEpisodes=1.1e6;
agent.AgentOptions.ExplorationModel.StandardDeviation = [0.0;0.015];
agent.AgentOptions.ExplorationModel.StandardDeviationDecayRate = [0;3e-4];
agent.AgentOptions.ExplorationModel.StandardDeviationMin = [0;0.010];
agent.AgentOptions.TargetPolicySmoothModel.StandardDeviation = [0.0;0.010];
agent.AgentOptions.TargetPolicySmoothModel.StandardDeviationDecayRate = [0;3e-4];
agent.AgentOptions.TargetPolicySmoothModel.StandardDeviationMin = [0;0.006];

% Train again (on noise plateau 4a).
trainingStats = train(agent,SS1env,trainingStats);

% Save again.
SS1env.reset();
save('initialAgent_p4_1e5.mat','agent','trainingStats','SS1env');

% Modify agent noise model for plateau 4b training.
trainingStats.TrainingOptions.MaxEpisodes=1.2e6;
agent.AgentOptions.ExplorationModel.StandardDeviation = [0.0;0.010];
agent.AgentOptions.ExplorationModel.StandardDeviationDecayRate = [0;1e-6];
agent.AgentOptions.ExplorationModel.StandardDeviationMin = [0;0.010];
agent.AgentOptions.TargetPolicySmoothModel.StandardDeviation = [0.0;0.006];
agent.AgentOptions.TargetPolicySmoothModel.StandardDeviationDecayRate = [0;1e-6];
agent.AgentOptions.TargetPolicySmoothModel.StandardDeviationMin = [0;0.006];

% Train again (on noise plateau 4b).
trainingStats = train(agent,SS1env,trainingStats);

% Save again.
SS1env.reset();
save('initialAgent_p4_2e5.mat','agent','trainingStats','SS1env');

% Train for 4c.
trainingStats.TrainingOptions.MaxEpisodes=1.3e6;
trainingStats = train(agent,SS1env,trainingStats);
SS1env.reset();
save('initialAgent_p4_3e5.mat','agent','trainingStats','SS1env');

% Train for 4d.
trainingStats.TrainingOptions.MaxEpisodes=1.4e6;
trainingStats = train(agent,SS1env,trainingStats);
SS1env.reset();
save('initialAgent_p4_4e5.mat','agent','trainingStats','SS1env');

% Train for 4e.
trainingStats.TrainingOptions.MaxEpisodes=1.5e6;
trainingStats = train(agent,SS1env,trainingStats);
SS1env.reset();
save('initialAgent_p4_5e5.mat','agent','trainingStats','SS1env');




