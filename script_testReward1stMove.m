% Script to test the rewards for the first move.
% Used to inform reward shaping (and making Figure S9).
clear;

% Create the spring slider environment.
SS1env = RL_SSenv();
obsInfo = getObservationInfo(SS1env);
actInfo = getActionInfo(SS1env);

% Manually prescribe the first move, which will trigger earthquake slip nucleation.
expBatch=struct('Observation',[],'Action',[],'Reward',[],'NextObservation',[],'IsDone',[]); i=1;
expBatch(i).Action={[+0.48;+1.00]}; SS1env.append(expBatch(i)); i=i+1;
%expBatch(i).Action={[-0.05;+0.9264]}; SS1env.append(expBatch(i)); i=i+1; % Okay, maybe also test for the second move.
%expBatch(i).Action={[-0.05;+0.82]}; SS1env.append(expBatch(i)); i=i+1; % or a third one too...
SS1env.reset();

% Get the current velocity.
Vi=SS1env.State(1);
dVb=10;
j=0;

% Generate the best guess, based on numerical estimation of normal stressing rate (Eqn S1.8).
dPdt_num=SS1env.ReiningAction();

% Sample the whole range.
%dPdt_list=actInfo.LowerLimit(2):0.02:actInfo.UpperLimit(2);
dPdt_list=0.70:0.001:1.70;
R_list=zeros(size(dPdt_list));

% Loop over every possible first action.
for i=1:length(dPdt_list)
    
    % Display percent completed.
    100*i/length(dPdt_list)
    
    % Get the action.
    action=[-0.05;dPdt_list(i)];
    
    % Step and record the reward.
    [obs,rew,done,~] = SS1env.step(action);
    R_list(i)=rew;
    V1=SS1env.State(1);
    
    % Check if this is the best stressing rate to halt the velocity.
    if(abs(V1-Vi)<dVb)
        dVb=abs(V1-Vi);
        j=i;
    end

    % Iterate.
    SS1env.reset();
    
end

%%

% Plot.
figure(4); clf;
plot(dPdt_list, R_list); hold on;
plot(dPdt_list(j), R_list(j),'o');
plot(dPdt_num*[1 1], ylim(),'--k');
plot([-3 +3], [0 0],':k');
xlabel('dP/dt (log_{10}[MPa/s])'); ylabel('Reward');
xlim([actInfo.LowerLimit(2) actInfo.UpperLimit(2)]);
set(gca,'xdir','reverse'); % Flipped to make pressure rates that cause earthquake on the right hand side.

% Report values.
dPdt_num
dPdt_list(j)
dPdt_num-dPdt_list(j)
