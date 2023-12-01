%%% Notes to myself and future readers about lessons learned.
% Try 20 (20 Nov 2023).

% This is my final tweak to the setup.  I'm slightly adjusting the final 
% bonus reward and the training plateaus for efficiency/stability now.
% 
% Odd, this one has started learning faster than any previous attempt.  The
% p2 epiphany is already starting by 1.5e5 episodes.  I'm not sure what to
% make of this change, as the agent has never learned this fast before.  It
% doesn't seem to have had any detrimental effects though.  There's still
% lots about reinforcement learning that I don't understand, apparently.
% Overall, this works though.  The agent is nicely trained by 3.5e5 
% episodes on p2.  Maybe some slight early trigger pulling, which coincides 
% with it's suboptimal actions near the last steps (40+). 
% 
% There's been some bits of performance dips and catastrophic forgetting at 
% p3, but the agent has landed back on the winning strategy.  The learning
% at this plateau is dedicated to fine-tuning the strategy now.  There also
% appears to be a bit of exploration in choices as sub-optimal strategies
% will appear and then disappear with further training.  Seems like this
% could be overcome by overtraining and then picking a preferable agent.
% 
% 
