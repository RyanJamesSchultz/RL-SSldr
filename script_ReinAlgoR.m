% Recursively call this script on sequentially modified guess-and-check action histories.
clear;

% Define some values.
Nsteps=10;
dPstep=-0.05;
Nround=2;
dV1=+0.01;
dVi=+0.03;
V_range=[];
dPdt_range=[+3 -3];
tol=10^-Nround;

% Get the required variables.
%FileName='AlgoRein_v24.mat'; N=62;
%FileName='AlgoRein_v44.mat'; N=51;
FileName='ReinSteps_temp5.mat'; N=51+5+5+5+3+2;

% Define the experience and environment.
env = RL_SSenv();
load(FileName,'expBatch','logVs');

% Manually specify the first step which will trigger earthquake slip nucleation.
for i=1:N
    env.append(expBatch(i));
end
i=i+1;

% Manually specify the first step which will trigger earthquake slip nucleation.
expBatch(i).Observation={env.State};
expBatch(i).Action={[+0.01;+3.000]};
[obs,rew,isdone,~] = env.step(expBatch(i).Action{1});
expBatch(i).Reward=rew;
expBatch(i).NextObservation={obs};
expBatch(i).IsDone=isdone;
env.append(expBatch(i));
logVs=obs(1);
logVt=min([obs(1)+dV1 logVs]);
i=i+1;

% Continue searching for the best next-step.
while(i<(Nsteps+N+1))
    
    % Get the current state.
    env.reset();
    
    % If there are no observations for the bounds yet, then get them.
    if(isempty(V_range))
        action=[dPstep;dPdt_range(1)];
        [obs,~,~,~] = env.step(action);
        V_range(1)=obs(1);
        env.reset();
        
        action=[dPstep;dPdt_range(2)];
        [obs,~,~,~] = env.step(action);
        V_range(2)=obs(1);
        env.reset();
    end
    
    % Get the next guess for the action value.
    dPdt=round(mean(dPdt_range),Nround,TieBreaker='plusinf'); % Round to simulate measurement precision.
    action=[dPstep;dPdt];
    
    % Test the candidate action.
    [obs,rew,isdone,~] = env.step(action);
    
    % Check if this action is good enough.
    if(min(abs(dPdt-dPdt_range))>tol)
        
        % If not, update the observation and bounds.
        if(obs(1)>logVt)
            V_range(2)=obs(1);
            dPdt_range(2)=dPdt;
        else
            V_range(1)=obs(1);
            dPdt_range(1)=dPdt;
        end
        
        % And try again.
        continue;
    end
    
    % Save if it is good enough.
    expBatch(i).Observation=expBatch(i-1).NextObservation;
    expBatch(i).Action={action};
    expBatch(i).Reward=rew;
    expBatch(i).NextObservation={obs};
    expBatch(i).IsDone=isdone;
    env.append(expBatch(i));
    
    % Iterate.
    dPdt_range=dPdt+[+0.3 -0.3];
    logVt=min([obs(1)+dVi logVs]);
    V_range=[];
    i=i+1;
    disp([num2str(i),' / ',num2str(Nsteps+N+1)]);
    
end



% Restart the environment, apply the history, and then plot.
env = RL_SSenv();
for i=1:length(expBatch)
    env.step(expBatch(i).Action{1});
end
env.plot();

% Save the results.
save('ReinSteps_temp.mat','expBatch','logVs');




