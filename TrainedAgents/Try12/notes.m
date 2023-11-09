%%% Notes to myself and future readers about lessons learned.
% Try 12 (30 July 2023).

% This simplification of the rewards function has fixed the prior crash.  
% Despite a long period of overtraining, the agent learns the first two 
% moves properly (after ~20,0000 episodes) and these lessons stick now too!
% There does appear to be a consistent bias towards the too-slow failure.
% There also is a tendency to rein-in velocity from whatever the current 
% step perturbed around (e.g., Agent_1e6.mat).  This probably complicates 
% the learning process, as the agent needs to learn how to rein-in for 
% every velocity near the start point, rather than just figure out how rein 
% to (and then stay at) the target velocity.  This is my own fault, as 
% I made that the agent's reward function.  Oops!  
% 
% It would make sense to work with the noise decay rate now for next steps 
% and maybe some more minor tweaks with the reward function.
% 
