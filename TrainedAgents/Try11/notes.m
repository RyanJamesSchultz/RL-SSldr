%%% Notes to myself and future readers about lessons learned.
% Try 11 (26 July 2023).

% This is a sort-of encouraging result.  This agent started learning a 
% winning policy more quickly than other setups I've tried so far 
% (Agent_1e5.mat).  After about 10,000 episodes, this setup can 
% fairly consistently find the best first move.   However, I still see a 
% crash after prolonged periods of learning (Agent_3e5).  This appears to
% be related to the reward function, which incentivizes getting closer to 
% causing an EQ, since this gives more slip.
% 
