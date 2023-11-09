function [Reward,End_Flag,End_type]=RewardFxn(env,SSc,SSp)
  % Function that determines the agent's reward, from their past actions,
  % in playing the spring slider 'game'.
  % 
  % Input:
  % SSc   --- Data structure from SpringSlider (current state), with fields: t, D, V, tau, Psi, & dt (all vectors are Nx1 sized).
  % t     --  Vector of time (s).
  % D     --  Vector of fault slip displacement (m).
  % V     --  Vector of fault slip velocities (m/s).
  % tau   --  Vector of shear stress on spring slider (MPa).
  % norm  --  Vector of normal stress on spring slider (MPa).
  % Psi   --  Vector of state variable.
  % dt    --  Vector of time-steps (s).
  % SSp   --- Data structure from SpringSlider (past state).
  % gamma --- Discount factor.
  %
  % Output:
  % Reward   --- Reward for the most recent actions.
  % End_Flag --- Flag for the end of the game.
  % 
  % Written by Ryan Schultz.
  
  % Initialize some values.
  End_Flag=false;
  End_type='continue';
  Reward=0;
  t_end=3600;
  Vfail=2e-1;
  Vslow=1e-5;
  Nwin=14;
  
  % Predefine rewards.
  ri=1e+1;      % Reward per MPa of pressure injected.
  rd=1e+7;      % Reward per m of fault slip.
  Pe=-1;        % Penalty for an earthquake.
  Ps=-10;       % Penalty for trying to slow down too much.
  Rs=Pe;        % Bonus reward for depleting all of the fault's shear stress.
  
  % End for choosing options that make the code crash.
  if(isnan(SSc.V(end)))
      End_Flag=true;
      End_type='error';
      return
  end
  
  % End for causing an earthquake.
  if(any(SSc.V>=Vfail))
      End_Flag=true;
      Reward=Pe;
      End_type='eq';
      return
  end
  
  % End for trying to go too slowly.
  if(any(SSp.V>=Vslow))
      if(SSc.V(end)<Vslow)
          End_Flag=true;
          Reward=Ps;
          End_type='backtrack';
          return
      end
  end
  
  % End if we pass the one hour mark.
  if(any((SSc.t-env.Te(1))>=t_end))
      End_Flag=true;
      End_type='timeout';
      return
  end
  
  % Find the amount of new positive/negative pressure change and slip.
  dN=max([min(SSp.norm)-min(SSc.norm) 0]);
  dD=max([max(SSc.D   )-max(SSp.D   ) 0]);
  dN2=max([max(SSc.norm)-max(SSp.norm) 0]);
  
  % More error handling for special case where the agent chooses to start by going backwards.
  if(dD<1e-7); dD=0; end
  
  % Reward linearly with injected volume (assuming proportional to pressure) and fault slip.
  Reward=Reward+dN*ri;
  Reward=Reward-dN2*ri/1;
  Reward=Reward+dD*rd;
  
  % Reward for getting to the goal (i.e., stable-postseismic-slip).
  if(any(SSc.norm<Nwin))
      End_Flag=true;
      Reward=Reward+Rs;
  end
  
  return
end