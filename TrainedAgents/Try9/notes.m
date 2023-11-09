%%% Notes to myself and future readers about lessons learned.
% Try 9 (24 July 2023).

% Okay, I've resolved the catastrophic forgetting (within 3e5 episodes at 
% least) by slowing learning rates and noise decay even further.  This 
% hyperparameter setup might even work as-is with more training episodes.  
% 
% Before that, I wanted to test some reward shaping with a slightly 
% greedier discount factor, to see if we can get the agent to learn better 
% choices more quickly.  Right now the range of 'close' velocities is 
% broad enough to lead to an unrecoverable failure within a couple of 
% steps.  Note that this choice will incorporate more of my personal bias 
% for 'correct' moves.
% 
