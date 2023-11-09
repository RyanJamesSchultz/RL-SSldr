%%% Notes to myself and future readers about lessons learned.
% Try 16 (12 Sept 2023).

% This attempt is aimed at making learning process rock solid.  Because of 
% all the instability issues I ran into.
% 
% I've done some considerable testing on p1 (on my laptop, no saved files) 
% to discern which approaches increase the stability of the learning 
% process.  Most importantly, the noise level dominates this process.  
% Having very low levels of noise encourages brittleness in the form of 
% catastrophic forgetting.  Pairing the target/exploration models with 
% different noise levels can partly safeguard against this.  Although, it's 
% not a siver-bullet, because I can still select levels of noise pairs that 
% can't even do p1.  As well, the learning rate causes catastrophic 
% forgetting.  Both if it's too fast or too slow.  I did a bit more 
% tuning of those values.  Based on tests, the newly selected values 
% appeared to be best for p1's stability.  For example, if I consider the 
% newly tuned learning rates combined with the tuned target/exploration
% smoothing factor, then all reasonable noise combinations have stable
% learning for p1 now.
% 
% Unfortunately, in all of the testing that I did, I couldn't manage to get 
% the critic to learn well.
% 
% Based on these tests, the approach I've selected for Try16 is to focus on 
% an exploration model at a safer (higher) level of noise.  The target 
% model is the tip-of-the-spear that scouts ahead and only provides some 
% (smoothed) bits of advanced knowledge.  This does come at the cost of
% doubling the training time, though.
% 
% This approach avoids the crash near 1e6 episodes i.e., the end of p2.  It 
% also performs slightly better than previous training attempts.  Although, 
% the p2_1e6 agent performs less well than the p2_7e5 agent.  Weird.  
% Something appears to be causing the agent to struggle at this point.  
% Could just be that the neural nets are too small to keep learning more?  
% Further training in p3 should be able to help distinguish this...
% 
% I think the test at p3 backs up the idea that the neural nets are too
% small.  The agent trys to learn new things but it costs performance from
% somewhere else.  Thus, nothing new is learned in these extra training
% episodes.  Thankfully, the agent is still 'stable' for it's learning 
% here.  The hyperparameter setup allows the agent to land back on the best
% configuration when making this mistake.  In this sense, this attempt has
% been a success!  
% 
% 

