%%% Notes to myself and future readers about lessons learned.
% Try 14 (29 Aug 2023).

% Okay, I'm getting really close.  I've tweaked the reward function to be
% sharper (on the broad Gaussian), penalized the failure types, and
% increased the learning rate for the critic (to offset its additional 
% inputs and larger model complexity).
% 
% I now know for certain that the p1 crash at ~1000 episodes is related to 
% the agent randomly starting closer to one of the failure types (e.g., too 
% slow), and then moving towards the opposite failure type (e.g., 
% stick-slip event).  The first two noise plateaus (p1 & p2) are mostly the 
% same as before (Try13); I've given a longer training time for p2 now and 
% p3 has a modest reduction in noise, before moving to p4 (Try 13's p3).  
% This is to still give a small potential for random failures to remind 
% the agent of the immediate consequences of poor decisions.  The reward 
% function (and failure penalty) should hopefully reinforce this lesson.
% 
% The changes I've made to the critic don't appear to fix the problems
% there.  I'm at a loss for how to fix this issue.
% 
% The changes I've made also don't seem to fix the catastrophic forgetting
% that happens at episode ~600,000 (p2).  Is this noise plateau related?
% 
% Well, I felt like I was getting closer.  However, this appears to be a 
% move in the wrong direction.  I'll revert back to Try13's reward function 
% and use a slower noise drop for Try 15.
% 

