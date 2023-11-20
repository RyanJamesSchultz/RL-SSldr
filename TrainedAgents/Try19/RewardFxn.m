function [Reward,End_Flag,End_type]=RewardFxn(env,SSc,SSp)
  % Function that determines the agent's reward, from their past actions,
  % in playing the spring-slider 'game'.
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
  Vfast=2e-1;
  Vslow=1e-5;
  Vtarg=4e-5;
  dlogVrEQ=log10(1.1);
  dlogVrTS=log10(1.2);
  dlogVa1EQ=log10(1.6);
  dlogVa1TS=log10(1.7);
  dlogVa2EQ=log10(1.1);
  dlogVa2TS=log10(1.2);
  MUwin=0.47;
  
  % Predefine rewards.
  ri=0;     % Reward per MPa of pressure injected.
  rd=0;     % Reward per m of fault slip.
  ru=0;     % Reward per change of mu.
  Rvr=+0;   % Reward for staying within the relative-velocity range.
  Rva=+2;   % Reward for staying within the absolute-velocity range.
  Pe=-2;    % Penalty for allowing an earthquake.
  Ps=-2;    % Penalty for slowing down too much.
  Rs=+4;    % Bonus reward for beating the game.
  
  % End for choosing options that make the code crash.
  if(isnan(SSc.V(end)))
      End_Flag=true;
      End_type='error';
      return
  end
  
  % End for causing an earthquake.
  if(any(SSc.V>=Vfast))
      End_Flag=true;
      Reward=Pe;
      End_type='EQ';
      return
  end
  
  % End for trying to go too slowly.
  if(any(SSp.V>=Vslow))
      if(SSc.V(end)<Vslow)
          End_Flag=true;
          Reward=Ps;
          End_type='Backtrack';
          return
      end
  end
  
  % End if we pass the one hour mark.
  if(any((SSc.t-env.Te(1))>=t_end))
      End_Flag=true;
      End_type='Timeout';
      return
  end
  
  % Find the amount of new positive/negative pressure change and slip.
  dN= max([min(SSp.norm)-min(SSc.norm) 0]);
  dN2=max([max(SSc.norm)-max(SSp.norm) 0]);
  dD= max([max(SSc.D   )-max(SSp.D   ) 0]);
  
  % More error handling for special case where the agent chooses to start by going backwards.
  if(dD<1e-7); dD=0; end
  
  % Reward linearly with injected volume (assuming proportionality to pressure) and fault slip.
  Reward=Reward+dN*ri;
  Reward=Reward-dN2*ri;
  Reward=Reward+dD*rd;
  
  % Reward for staying within a range of the last velocity.
  dlogV=log10(SSc.V(end))-log10(SSp.V(end));
  if(dlogV>0)
      Reward=Reward+Rvr*normpdf(abs(dlogV),0,dlogVrEQ)*dlogVrEQ*sqrt(2*pi());
  else
      Reward=Reward+Rvr*normpdf(abs(dlogV),0,dlogVrTS)*dlogVrTS*sqrt(2*pi());
  end

  % Reward for staying within a broad/narrow range of the target velocity.
  dlogV=log10(SSc.V(end))-log10(Vtarg);
  if(dlogV>0)
      Reward=Reward+Rva*normpdf(abs(dlogV),0,dlogVa1EQ)*dlogVa1EQ*sqrt(2*pi());
      Reward=Reward+Rva*normpdf(abs(dlogV),0,dlogVa2EQ)*dlogVa2EQ*sqrt(2*pi());
  else
      Reward=Reward+Rva*normpdf(abs(dlogV),0,dlogVa1TS)*dlogVa1TS*sqrt(2*pi());
      Reward=Reward+Rva*normpdf(abs(dlogV),0,dlogVa2TS)*dlogVa2TS*sqrt(2*pi());
  end
  
  % Reward for changing mu.
  MUp=SSp.tau(end)/SSp.norm(end);
  MUc=SSc.tau(end)/SSc.norm(end);
  dMU=MUp-MUc;
  dMU=max([0 dMU]);
  Reward=Reward+dMU*ru;
  
  % Reward for getting to the end-point goal.
  if(MUc<MUwin)
      End_Flag=true;
      Reward=Reward+Rs;
      End_type='Success!';
  end
  
  return
end