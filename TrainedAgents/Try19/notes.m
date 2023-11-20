%%% Notes to myself and future readers about lessons learned.
% Try 19 (10 Nov 2023).

% This attempt is the exact same as Try18, just with minor tweaks to the 
% reward function to prevent the agent from pulling the trigger too early  
% on the stick-slip event.  Doing simple math with the agent's discounted 
% reward function, I'd expect that if the final win reward is greater than 
% twice the individual step reward, then the agent will pull the trigger on 
% a stick-slip event ASAP.  If it's less, then it should draw out the 
% number of steps.
% 
% The agent is able to successsfully beat the game by episode 4e5 in p2; 
% this attempt also fixes the early stick-slip problem.  These agents do 
% lack polish in later actions (step 35+).  However, this improves with 
% training, as 4e5 is already better than the 3e5 agent (and 5e5 is better
% yet).  These agents don't appear to learn too much for the episodes now, 
% though.  I should consider pruning back the episode count in this 
% plateau.  Again, I'm bumping into (small) catastrophic forgetting issues 
% after reaching peak performance.  It's good that I've already thoroughly 
% explored how to address this problem.
% 
% Oh boy, training at p3 is oppressively slow. And it bumped into
% catastrophic forgetting before the first 1e5 training episodes there.  I 
% guess I wasn't quite as thorough about this as I had thought.  On the 
% plus side, training does (eventually) recover from this.  I'm guessing 
% the problem here is analagous to the prior struggle point: the agent 
% isn't incentivized enough with the end-point goal reward, so it tries 
% actions that drag out the game for more reward - eventually sabotaging 
% itself.  To fix this, I'll try increasing the final reward, but still 
% keep it less than twice the individual step reward.
% 
% 
