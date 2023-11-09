%%% Notes to myself and future readers about lessons learned.
% Try 13 (6 Aug 2023).

% This further simplification of the reward function works very well.  
% From here, I'm working on how to understand and optimize the trade-offs
% from exploration-exploitation.  The learning process occurs at different 
% rates for each plateau of exploration noise used during training, so I 
% rewrote the training script to address this.
% 
% The first plateau (p1) is essentially just to get any naive agent to make
% the first move approximately right.  Even if the agent is trained at
% great length here (up to 3e5 episodes), nothing significantly new is 
% learned.  This is because the noise here is too large to let an agent 
% play the game effectively - a single random draw of noise could end the 
% game at any given step.  By episode 20,000 most every naive agent seems 
% to have learned the roughly correct first move.  This learning process 
% always appears to be the same: start by making random guesses for about 
% 1,000 episodes, have a poor-performance crash for another 1,000 episodes, 
% and then land on the correct first move to make (and finally stay there 
% :D).  Not quite sure I fully understand why this is yet.
% 
% The second plateau (p2) allows the agent to refine the first move, while
% still allowing enough noise for subsequent moves to be explored.  By 
% episode ~300,000 most every novice agent seems to have learned the 
% correct ~10 first moves.  By episode ~400,000 most every novice agent 
% seems to have learned the correct ~15 first moves.  Furthermore, these 
% agents perform near the top-end of training scores, when tested without 
% exploration noise.  Despite these sucesses, it is still bothering me that 
% the critic doesn't get much better with additional training here...
% Maybe it's learning rate is too low?
% 
% Important lesson here was that if I dropped the noise too quickly (i.e., 
% going to p3), then I'd end up with catastraophic forgetting 
% (p3/Agent_p3.mat).  Not totally sure I understand why this is.  I'm 
% guessing it has to do with the agent not sampling enough poor decisions, 
% so it overwrites good strategies - essentially taking these old lessons 
% for granted.  If this is correct, it might mean that there is a base 
% level of noise I can't go below.  This failure ocurred when testing at a 
% noise level of 0.01 log10(dP/dt[MPa]) and I changed from p2 to p3 after 
% 400,000 epsidoes of p2 training (p3/Agent_p2_4e5).  Keeping the noise 
% level at 0.02 log10(dP/dt[MPa]) samples the entire narrow Gaussian reward 
% (plus some of the broad Gaussian reward).  I'm hoping this should 
% hopefully be enough to finalize the agent.
% 
% If I continue training at the p2 noise level (p3/Agent_p2_7e5), this 
% prevents the catastrophic forgetting that I encountered with p3.  This is
% a huge relief.  This is also a bit of a pain, as it means we'll have to
% train this very slowly...  I'll have to think about this.
% 
% Apparently there is some sort of quirk with resuming RL agent training in 
% Matlab.  It looks like the noise decay parameters reset if you ask the
% training to continue.  This explains the 'drops' in performance for 
% continued p2 training.  Ugh...
% 
% Seems like p2 noise can't learn much beyond 1e6 episodes (see 
% p3/Agent_p2_1e6).  This is probably because the amount of noise, with a 
% handful of consecutive bad draws, won't let the agent make it it the end.  
% 
% 

