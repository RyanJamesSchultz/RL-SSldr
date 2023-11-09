% Script that trains a reinforcement learning agent to rein in a spring-slider fault.
% Try 4.
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
% dP:     -2 to +2  MPa.
% dP/dt:  -3 to +3  log10[MPa/s].

% Overloading the actor's scaling layer to always output the same dP step.
scale(1)=0.0; bias(1)=-0.05;

% Further overloading the actor's scaling layer to restrict dP/dt choices [+0.7 to +1.7].
scale(2)=0.5; bias(2)=1.2;




%%% Create the Agent.
% Number of neurons (network width).
L = 100;

% Make the critic.
% Main path.
mainPath = [ ...
    featureInputLayer(prod(obsInfo.Dimension),'Name','ObsInputLayer'),...
    fullyConnectedLayer(L,'Name','FC_O1'),...
    reluLayer('Name','ReLu_O1'),...
    fullyConnectedLayer(L,'Name','ObsMergeLayer'),...
    additionLayer(2,'Name','MergedLayer'),...
    reluLayer('Name','ReLu_M1'),...
    fullyConnectedLayer(L,'Name','FC_M2'),...
    reluLayer('Name','ReLu_M2'),...
    fullyConnectedLayer(1,'Name','QValueOutput')
    ];

% Action path.
actionPath = [ ...
    featureInputLayer(prod(actInfo.Dimension),'Name','ActionInputLayer'),...
    fullyConnectedLayer(L,'Name','ActionMergeLayer'),...
    ];

% Assemble paths.
criticNet = layerGraph(mainPath);
criticNet = addLayers(criticNet,actionPath);    
criticNet = connectLayers(criticNet,'ActionMergeLayer','MergedLayer/in2');

% Convert to deep learning network object (and display).
criticNet = dlnetwork(criticNet);
%figure(1); clf;
%plot(criticNet);
%title('Critic-Net');
%summary(criticNet);

% Create the critic using the specified network and the environment action and observation specifications. 
critic = rlQValueFunction(criticNet,obsInfo,actInfo,'ObservationInputNames','ObsInputLayer','ActionInputNames','ActionInputLayer');

% Make the actor.
% Start with a deep network.
actorNet = [
    featureInputLayer(prod(obsInfo.Dimension),'Name','ObsInputLayer')
    fullyConnectedLayer(L,'Name','FC_A1')
    reluLayer('Name','ReLu_A1')
    fullyConnectedLayer(L,'Name','FC_A2')
    reluLayer('Name','ReLu_A2')
    fullyConnectedLayer(L,'Name','FC_A3')
    reluLayer('Name','ReLu_A3')
    fullyConnectedLayer(2,'Name','FC_A4')
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
criticOptions = rlOptimizerOptions('LearnRate',1e-3,'GradientThreshold',1,'L2RegularizationFactor',1e-4);
actorOptions  = rlOptimizerOptions('LearnRate',1e-4,'GradientThreshold',1,'L2RegularizationFactor',1e-4);

% Specify the DDPG agent options using rlDDPGAgentOptions, include the options for the actor and the critic.
agentOptions = rlDDPGAgentOptions('SampleTime',0.003,...
    'ActorOptimizerOptions',actorOptions,...
    'CriticOptimizerOptions',criticOptions,...
    'ExperienceBufferLength',1e4,...
    'DiscountFactor',0.99);
agentOptions.NoiseOptions.StandardDeviation = [0.0;0.10];
agentOptions.NoiseOptions.StandardDeviationDecayRate = 2e-5;
agentOptions.NoiseOptions.StandardDeviationMin = [0;1e-3];

% Create the DDPG agent using the actor, critic, and agent options.
agent = rlDDPGAgent(actor,critic,agentOptions);




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
maxepisodes = 1e6;
maxsteps = 100;
PlotFlag='none';
trainingOpts = rlTrainingOptions('MaxEpisodes',maxepisodes,...
    'MaxStepsPerEpisode',maxsteps,...
    'Verbose',false,...
    'Plots',PlotFlag,...
    'StopTrainingCriteria','AverageReward',...
    'ScoreAveragingWindowLength',300,...
    'StopTrainingValue',300,...
    'UseParallel',true);

% Train the agent.
trainingStats = train(agent,SS1env,trainingOpts);

% Save the agent.
SS1env.reset();
save('initialAgent.mat','agent','trainingStats','SS1env');









