% A script that will automatically define the action-history to rein-in the spring-slider system.
% This algorithm uses the numerical estimation of normal stressing rate (Eqn S1.8) for a guided-check.
clear;

% Define some values.
Nsteps=20;
dPstep=-0.05;
Cf=-0.161;
dCf=+0.002;

% Define the experience and environment.
env = RL_SSenv();
expBatch=struct('Observation',[],'Action',[],'Reward',[],'NextObservation',[],'IsDone',[]); i=1;

% Manually specify the first step which will trigger earthquake slip nucleation.
expBatch(i).Observation={env.State};
expBatch(i).Action={[+0.480;+1.000]};
[obs,rew,isdone,~] = env.step(expBatch(i).Action{1});
expBatch(i).Reward=rew;
expBatch(i).NextObservation={obs};
expBatch(i).IsDone=isdone;
env.append(expBatch(1));
logVs=log10(env.Oc.V(end));
i=i+1;

% Continue searching for the best next-step.
while(i<Nsteps)
    
    % Get the current state.
    env.reset();
    V=env.Oc.V(end);
    
    % Generate a candidate action, based on numerical estimation of normal stressing rate (Eqn S1.8).
    dPdt=env.ReiningAction();
    action=[dPstep;dPdt+Cf];
    
    % Apply the candidate action.
    [obs,rew,isdone,~] = env.step(action);
    
    % Check if this action is good enough?
    if(env.Oc.V(end)>V)
        Cf=Cf+dCf;
    end
    
    % Save if it is good enough.
    expBatch(i).Observation=expBatch(i-1).NextObservation;
    expBatch(i).Action={action};
    expBatch(i).Reward=rew;
    expBatch(i).NextObservation={obs};
    expBatch(i).IsDone=isdone;
    env.append(expBatch(i));
    
    % Iterate.
    i=i+1;
    disp([num2str(i),' / ',num2str(Nsteps)]);
    
end



% Restart the environment, apply the history, and then plot.
env = RL_SSenv();
for i=1:length(expBatch)
    env.step(expBatch(i).Action{1});
end
env.plot();

% Save the results.
save('ReinSteps_temp.mat','expBatch','logVs');




