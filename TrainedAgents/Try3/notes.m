%%% Notes to myself and future readers about lessons learned.
% Try 3 (24 June 2023).

% This was one of the first encouraging results!  The agent is clearly
% learning now (e.g., Agent_1e6.mat).  However, there's a couple of issues
% that have made this one less than straightforward - my thoughts were this 
% was related to the noise model for exploration/exploitation and a Q 
% overestimation bias.  Ultimately, catastrophic forgetting ends up ruining 
% the agent (Agent_2e6.mat).
% 
% I also ran this agent before fully understanding how the Ornstein
% Uhlenbeck action noise works.  The agent not becoming better on average
% is a result of the noise being too high - so we're essentially exploring 
% nothing but noise for a million+ episodes.
% 
% My apologies, I didn't think to include the script_DDPG.m file 
% (or even these notes) when I first started working on this project.  Some 
% of the parameters set can be found by looking at the agent class, within 
% the *.mat files.
% 
