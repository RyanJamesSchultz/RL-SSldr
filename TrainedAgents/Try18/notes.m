%%% Notes to myself and future readers about lessons learned.
% Try 18 (6 Nov 2023).

% This attempt is the exact same as Try17 (L=256), now fixing the bug that 
% inadequately restricted the agent's action space.  A clean slate!
% 
% This attempt is showing real promise.  After training through the p2 
% epiphany, the agent is clearly better than prior tries in every metric.  
% Looks like the training still plateaus out though, and in a comparable 
% way to the prior tests (Try 13-16).  The results do have an odd look to 
% them, though: almost something bimodal, where there's a set of episodes 
% that do really well and then suddenly fail at the limits of the agent's 
% experience.  The best performance seems to have been right after the 
% epiphany.  There's a small performance crash that I'm not sure I really 
% understand.  
% 
% This is my first successfully trained agent!  The agent (Agent_p2_4e5) 
% was able to beat the spring-slider game :)  I wasn't expecting it to pull
% the trigger on a stick-slip event so early.  I'm genuinely surprised 
% here!  The rules of the game were to stay below the given slip velocity 
% upper bound, and the agent did exactly that.  I'm curious what will 
% happen with additional training.  Will the agent learn to take more 
% steps?  That seems logical, since it would get more reward before ending 
% the game.  Although, this will depend on the discounted reward, which 
% I'd need to think about more rigorously.
% 
% Actually, that bimodal distribution is likely from the agent winning the
% game.  All of the peak scores are similar because they were able to
% finish.
% 
