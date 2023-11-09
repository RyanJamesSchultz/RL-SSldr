%%% Notes to myself and future readers about lessons learned.
% Try 17 (24 Sept 2023).

% This attempt is the exact same as Try16, just playing with the size of 
% the neural nets.  Some smaller scale laptop testing revealed that the 
% agent wasn't even able to adequately learn the first step when L=8, and 
% struggled with p1 when L=16.  Just as an FYI.
% 
% Increasing the network size to L=256 let the agent get to the same point 
% for p2.  Overall, the stability is recognizably better at p2 (compared to 
% Try16).  Although, I'm still bumping into the same training issues which 
% can be seen in around 8e5.  As a side note, I likely don't need to train 
% up to 1e6 episodes for p2.  Things are already working pretty well by 4e5 
% and the best was reached by 7e5.  Another side note, the decay of the 
% noise looks to be much slower than what I expected.  I thought the decay 
% would be completely done well before 1e5, but there's a clear reward bump 
% at this point.  I'll modify future noise decays to be far more 
% aggressive, as this slow transition is just wasted training time.
% 
% For the L=256 architecture at p3, the agent appears to have stabilized 
% just after 1e5 and it becomes more stable the further into the training. 
% Looks like catastrophic forgetting problems are a thing of the past now.  
% Unfortunately,training here didn't allow the agent to have another 
% 'epiphany' that makes it figure out how to finish the second half of the 
% steps.  Whelp, onwards to L=512...
% 
% Training at L=512 gets to exactly the same snag at p2.  It also bumped 
% into a catastrophic forgetting issue at 4e5 episodes (guess I spoke too 
% soon).  This looks like it might be an exploration noise issue, rather 
% than a network size issue.
% 
% In reviewing prior training details, after p1 the agents tend to make the 
% same constant action guess for the first (and subsequent) steps.  The p2 
% epiphany comes after the agent realizes that there's an approximately 
% linear change in reining action (dP/dt) with changes in step number.  The 
% struggle point (i.e., steps 27-30) is also when the reining action really 
% starts to depart from this linear trend.  Thus, getting past this 
% struggle point actually might be an exploration noise issue.  Supporting 
% this, the L=256 p3 training often doesn't even get to the struggle point 
% before failing.  I'm going to revert back to training the L=256 network, 
% add a p4, and then see what happens.
% 
% Training of L=256 at p4 didn't bumped into catastrophic issues.   Metrics 
% of step number, episode reward, and average reward/step improved - mostly 
% by encountering fewer early-game failures.  There's even parts where the 
% agent is starting to get close to the winning strategy; where there's a 
% significant increase in both the number of steps and total reward (i.e., 
% 1.95e6 and 2.1e6 with reward>100 and steps>27).  However, the agent seems 
% to quickly unlearn this.  I'm going to try adding a p5 to exhaustively  
% check if adjusting exploration noise could work.
% 
% Training of L=256 at p5 has gotten an agent trained further into the
% struggle point that any prior attempts (1e5).  Forget this stuff.
% 
% Oh boy, I just noticed that the struggle point happens because I've 
% restricted the network's action-space to have a lower bound of 0.7 
% log10[MPa/s].  This means that the agent can't make proper choices after 
% step 24.  This explains why it can't further than this point.  This is a 
% deeply embarassing mistake :S  Ugh, I spent a ton of time trying to 
% 'solve' this issue with RL tuning.  
% 
% In retrospect, what I was seeing at the struggle point makes a bit more 
% sense now.  The agent was trying to find creative ways to get a bit more 
% reward by squeezing in just a few more steps.  Like by taking a handful 
% of sub-optimal overshoot actions close to the end, so that the 
% spring-slider would take more time transitioning toward the inevitable 
% too-slow game over (e.g., L_256/Agent_p5_1e5).  A gambit that trades 
% upfront reward for later reward.  Neat.
% 
% 



