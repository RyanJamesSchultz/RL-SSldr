% Simple script to diagnose how well an agent has been learning.
clear;

% Averaging window length.
n=1000;

% Load environment & agent.
load('TrainedAgents/Try20/Agent_p3_25e4.mat');
SS1env.reset();

% Plot.
figure(4); clf;
ax1=subplot(411);
plot(trainingStats.EpisodeIndex,trainingStats.EpisodeSteps,'.b'); hold on; 
plot(trainingStats.EpisodeIndex,movmean(trainingStats.EpisodeSteps,n),'-k');
xlabel('Episode Number'); ylabel('Step Number');
ax2=subplot(412);
plot(trainingStats.EpisodeIndex,trainingStats.EpisodeReward,'.b'); hold on; 
plot(trainingStats.EpisodeIndex,movmean(trainingStats.EpisodeReward,n),'-k');
xlabel('Episode Number'); ylabel('Episode Reward');
ax3=subplot(413);
y=trainingStats.EpisodeReward./trainingStats.EpisodeSteps;
plot(trainingStats.EpisodeIndex,y,'.b'); hold on; 
plot(trainingStats.EpisodeIndex,movmean(y,n),'-k');
xlabel('Episode Number'); ylabel('Average Episode Reward per Step');
ax4=subplot(414);
plot(trainingStats.EpisodeIndex,trainingStats.EpisodeQ0,'.r'); hold on; 
plot(trainingStats.EpisodeIndex,movmean(trainingStats.EpisodeQ0,n),'-k');
xlabel('Episode Number'); ylabel('Episode Q0');
linkaxes([ax1 ax2 ax3 ax4],'x');

