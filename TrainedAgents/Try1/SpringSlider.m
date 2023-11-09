function [Output]=SpringSlider(Params,Solver,Flags)
  % Function that solves the spring-slider ODE.
  % Note: V = dD/dt, G = dPsi/dt, Psi = f0+b*log(V0*Theta/Dc).
  % 
  % Input:
  % Params --- Input structure with fields: f0, V0, a, b, Dc, eta, N, k, dtaudt, D0, tau0, & Psi0.
  % f0     --  Reference friction coefficient.
  % V0     --  Reference slip velocity (m/s).
  % a      --  Direct effect friction parameter.
  % b      --  State evolution friction parameter.
  % Dc     --  State evolution distance (m).
  % eta    --  Radiation-damping coefficient (MPa*s/m).
  % N      --  Effective normal stress (MPa).
  % k      --  Fault stiffness, k<kcr gives stick-slip (MPa/m).
  % dtaudt --  Stressing rate (shear stress increases at constant rate in absence of slip) (MPa/s).
  % D0     --  Initial slip distance (m).
  % tau0   --  Shear stress (MPa).
  % Psi0   --  Initial state variable.
  % Flags     --- Flag structure with fields: Tsteps, & StateLaw.
  % Tsteps    --  Flag for solver time-stepping type.
  % StateLaw  --  Flag for state evolution law.
  % Injection --  Flag for changing normal stress via injection induced fluid pressure change.
  % StateNorm --  Flag for adding normal stress change to state evolution.
  % FlashHeat --  Flag for adding flash heating, which gives more high-velocity frictional weakening.
  % 
  % 
  % Output:
  % Output --- Output structure with fields: t, D, V, tau, norm, Psi, & dt (all vectors are Nx1 sized).
  % t      --  Vector of time (s).
  % D      --  Vector of fault slip displacement (m).
  % V      --  Vector of fault slip velocities (m/s).
  % tau    --  Vector of shear stress on spring slider (MPa).
  % norm   --  Vector of normal stress on spring slider (MPa).
  % Psi    --  Vector of state variable.
  % dt     --  Vector of time-steps (s).
  % 
  % References:
  % Beeler, N. M., Tullis, T. E., & Goldsby, D. L. (2008). Constitutive relationships and physical basis of fault strength due to flash heating. Journal of Geophysical Research: Solid Earth, 113(B1), doi: 10.1029/2007JB004988.
  % Butcher (1996). A history of Runge-Kutta methods. Applied numerical mathematics, 20(3), 247-260, doi: 10.1016/0168-9274(95)00108-5.
  % Dieterich (1979). Modeling of rock friction: 1. Experimental results and constitutive equations. Journal of Geophysical Research: Solid Earth, 84(B5), 2161-2168, doi: 10.1029/JB084iB05p02161.
  % Kato & Tullis (2003). Numerical simulation of seismic cycles with a composite rate-and state-dependent friction law. Bulletin of the Seismological Society of America, 93(2), 841-853, doi: 10.1785/0120020118.
  % Linker & Dieterich (1992). Effects of variable normal stress on rock friction: Observations and constitutive equations. Journal of Geophysical Research: Solid Earth, 97(B4), 4923-4940, doi: 10.1029/92JB00017.
  % Marone (1998). Laboratory-derived friction laws and their application to seismic faulting. Annual Review of Earth and Planetary Sciences, 26(1), 643-696, doi: 10.1146/annurev.earth.26.1.643.
  % Nagata, Nakatani, & Yoshida (2012). A revised rate and state‐dependent friction law obtained by constraining constitutive and evolution laws separately with laboratory data. Journal of Geophysical Research: Solid Earth, 117(B2), doi: 10.1029/2011JB008818.
  % Perrin, Rice, & Zheng (1995). Self-healing slip pulse on a frictional surface. Journal of the Mechanics and Physics of Solids, 43(9), 1461-1495, doi: 10.1016/0022-5096(95)00036-I.
  % Rice, Lapusta, & Ranjith (2001). Rate and state dependent friction and the stability of sliding between elastically deformable solids. Journal of the Mechanics and Physics of Solids, 49(9), 1865-1898, doi: 10.1016/S0022-5096(01)00042-4.
  % Ruina (1983). Slip instability and state variable friction laws. Journal of Geophysical Research: Solid Earth, 88(B12), 10359-10370, doi: 10.1029/JB088iB12p10359.
  % Wang, T. A., & Dunham, E. M. (2022). Hindcasting injection-induced aseismic slip and microseismicity at the Cooper Basin Enhanced Geothermal Systems Project. Scientific Reports, 12(1), 19481, doi: 10.1038/s41598-022-23812-7.
  % 
  % Originally written by Eric Dunham [e.g., Wang & Dunham, 2022], modified by Ryan Schultz.
  
  % Solve using constant time steps.
  if(strcmpi(Flags.Tsteps,'constant'))
      
      % Predefine some values.
      Ns=length(Params.t); % Number of time steps.
      dt=Params.tmax/Ns; % Time step (s).
      t=Params.t; % Time vector (s).
      
      % Preallocate the output vectors.
      D=nan(Ns+1,1);
      V=nan(Ns+1,1);
      tau=nan(Ns+1,1);
      Psi=nan(Ns+1,1);
      Sn=nan(Ns+1,1);
      
      % Initialize for the first time point.
      D(1)=Params.D0;
      Psi(1)=Params.Psi0;
      
      % Solve at each time-step.
      for i=1:Ns
          
          % Compute the fault fluid pressure at this time.
          ti=Params.t(i);
          if(strcmpi(Flags.Injection,'on'))
              %[~,j]=min(abs(ti-Params.t)); ExtraP.P=Params.P(j);
              %ExtraP.P=interp1(Params.t,Params.P,ti,'linear',0);
              ExtraP.P=qinterp1(Params.t,Params.P,ti,1); % This is significantly faster than Matlab's included functions.
          else
              ExtraP.P=0;
          end
          if(strcmpi(Flags.StateNorm,'on'))
              %[~,j]=min(abs(ti-Params.t)); ExtraP.dNdt=Params.dNdt(j);
              %ExtraP.dNdt=interp1(Params.t,Params.dNdt,ti,'linear',0);
              ExtraP.dNdt=qinterp1(Params.t,Params.dNdt,ti,1); % This is significantly faster than Matlab's included functions.
          end

          % Fourth-order Runge-Kutta (RK) solutions [Butcher, 1996].
          [V1,G1,tau1]=sliderODE( D(i)          , Psi(i)          , ti       , Params,ExtraP,Flags);
          [V2,G2,  ~ ]=sliderODE( D(i)+0.5*dt*V1, Psi(i)+0.5*dt*G1, ti+0.5*dt, Params,ExtraP,Flags);
          [V3,G3,  ~ ]=sliderODE( D(i)+0.5*dt*V2, Psi(i)+0.5*dt*G2, ti+0.5*dt, Params,ExtraP,Flags);
          [V4,G4,  ~ ]=sliderODE( D(i)+    dt*V3, Psi(i)+    dt*G3, ti+    dt, Params,ExtraP,Flags);
          
          % Save the RK solutions.
          V(i)=V1;
          tau(i)=tau1;
          D(i+1)=D(i)+dt/6*(V1+2*V2+2*V3+V4);
          Psi(i+1) = Psi(i)+dt/6*(G1+2*G2+2*G3+G4);
          Sn(i)=Params.N-ExtraP.P;
          
      end
      
      % Stuff everything into the output data structure.
      Output.t=t;
      Output.D=D;
      Output.V=V;
      Output.tau=tau;
      Output.norm=Sn;
      Output.Psi=Psi;
      Output.dt=dt;
  end
  
  % Solve using adaptive time steps.
  if(strcmpi(Flags.Tsteps,'adaptive'))
      
      % Predefine some values.
      tol=Solver.tol;       % Error tolerance.
      dt=Solver.dt;         % Initial time step (s).
      dtmax=Solver.dtmax;   % Maximum allowed time step (s).
      safety=Solver.safety; % Safety factor.
      q=2;                  % Accuracy order for update.
      t=Params.t(1);        % Start time.
      %dt2=1e-5;
      
      % Initialize solution for first data point.
      ta=t;
      Da=Params.D0;
      Psia=Params.Psi0;
      Pa=interp1(Params.t,Params.P,t,'linear',0); ExtraP.P=Pa;
      dNdt=interp1(Params.t,Params.dNdt,t,'linear',0);  ExtraP.dNdt=dNdt;
      [V1,G1,tau1]=sliderODE(Da(end),Psia(end),t,Params,ExtraP,Flags);
      Va=V1;
      taua=tau1;
      err=0;
      dta=dt;
      
      % Solve at each time step, until end time.
      while t<Params.tmax
          
          % Error handling, for the case that we overshoot the end time.
          if t+dt>Params.tmax
              dt=Params.tmax-t;
          end

          % Compute the fault fluid pressure at this time.
          if(strcmpi(Flags.Injection,'on'))
              %[~,j]=min(abs((t+dt)-Params.t)); ExtraP.P=Params.P(j);
              %ExtraP.P=interp1(Params.t,Params.P,t+dt,'linear',0);
              ExtraP.P=qinterp1(Params.t,Params.P,t+dt,1); % This is significantly faster than Matlab's included functions.
          else
              ExtraP.P=0;
          end
          if(strcmpi(Flags.StateNorm,'on'))
              %[~,j]=min(abs((t+dt)-Params.t)); ExtraP.dNdt=Params.dNdt(j);
              %ExtraP.dNdt=interp1(Params.t,Params.dNdt,t+dt,'linear',0);
              ExtraP.dNdt=qinterp1(Params.t,Params.dNdt,t+dt,1); % This is significantly faster than Matlab's included functions.
          end
          
          % Three-stage Runge-Kutta (RK) method, with embedded error estimate [Butcher, 1996].
          [V2,G2,~]=sliderODE( Da(end)+0.5*dt*V1    ,Psia(end)+0.5*dt*G1    ,t+0.5*dt,Params,ExtraP,Flags);
          [V3,G3,~]=sliderODE( Da(end)+dt*(-V1+2*V2),Psia(end)+dt*(-G1+2*G2),t+dt    ,Params,ExtraP,Flags);
          
          % Second-order update.
          D2  =Da(end)  +dt/2*(V1+V3);
          Psi2=Psia(end)+dt/2*(G1+G3);
          
          % Third-order update.
          D3  =Da(end)  +dt/6*(V1+4*V2+V3);
          Psi3=Psia(end)+dt/6*(G1+4*G2+G3);
          
          % Local error estimate.
          er = norm([D2-D3; Psi2-Psi3]);
          
          % Only keep the update if the error is less than the tolerance.
          if er<tol
              
              % Update solution.
              t=t+dt;
              ta=[ta; t];
              Pa=[Pa; ExtraP.P];
              Da=[Da; D3];
              Psia=[Psia; Psi3]; % Use third-order update.
              
              % Store error and time step.
              err=[err; er];
              dta=[dta; dt];
              
              % Evaluate stage 1 values for next time step.
              [V1,G1,tau1]=sliderODE(Da(end),Psia(end),t,Params,ExtraP,Flags);
              Va=[Va; V1]; 
              taua=[taua; tau1]; % Stage 1 values are stored.
          end
          
          % Exit with an error, if can solve for V.
          if(any(isnan([V1, V2, V3])))
              Output.t=NaN;
              Output.V=NaN;
              Output.D=NaN;
              Output.Psi=NaN;
              Output.tau=NaN;
              Output.norm=NaN;
              Output.dt=NaN;
              return
          end
          
          % Adjust time step.
          dt=safety*dt*(tol/er)^(1/(q+1));
          dt=min(dt,dtmax);
          
      end
      
      % Stuff everything into the output data structure.
      Output.t=ta;
      Output.V=Va;
      Output.D=Da;
      Output.Psi=Psia;
      Output.tau=taua;
      Output.norm=Params.N-Pa;
      Output.dt=dta;
  end
  
  return
end











%%%% SUBROUNTINES.

function [V,G,tau] = sliderODE(D,Psi,t,Params,ExtraP,Flags)
  % Solver for spring-slider ODE.
  
  % Evaluate shear stress when V=0.
  tauLock = Params.tau0+Params.dtaudt*t-Params.k*D;
  
  % Set bounds on V for root-finding.
  if(tauLock>0)
      Vmin = 0;
      Vmax = tauLock/Params.eta;
  else
      Vmin = tauLock/Params.eta;
      Vmax = 0;
  end
  
  % Solve the stress=strength equation for V.
  V = hybrid_f0(@(V) equilSnS(V,tauLock,Psi,Params,ExtraP,Flags) ,Vmin,Vmax,1e-50,1e-6);
  %V = fzero(@(V) equilSnS(V,tauLock,Psi,Params,ExtraP,Flags), 1e-1,optimset('TolX',1e-50));
  
  % Exit with an error, if V isn't solved for.
  if(isnan(V))
      V=NaN;
      G=NaN;
      tau=NaN;
      return;
  end
  
  % Next, evaluate tau.
  tau=tauLock-Params.eta*V;
  
  % Finally, estimate state evolution: G = dPsi/dt & Psi = f0+b*log(V0*Theta/Dc).
  if(strcmpi(Flags.StateLaw,'aging')) % Aging (or slowness) law [Dietrich, 1979].
      G = (Params.b.*Params.V0./Params.Dc)*(exp((Params.f0 - Psi)/Params.b) - V/Params.V0);
      %Theta=exp((Psi-Params.f0)/Params.b)*Params.Dc/Params.V0;
      %dTdt=1-Theta*V/Params.Dc;
      %G=dTdt*Params.b/Theta;
  elseif(strcmpi(Flags.StateLaw,'slip')) % Slip law [Ruina, 1983].
      f=tau/(Params.N-ExtraP.P);
      fss=Params.f0+(Params.a-Params.b)*log(V/Params.V0);
      G=(-V/Params.Dc)*(f-fss);
      %Theta=exp((Psi-Params.f0)/Params.b)*Params.Dc/Params.V0;
      %dTdt=(-Theta*V/Params.Dc)*log(Theta*V/Params.Dc);
      %G=dTdt*Params.b/Theta;
  elseif(strcmpi(Flags.StateLaw,'PRZ')) % PRZ law [Perrin et al., 1995].
      Theta=exp((Psi-Params.f0)/Params.b)*Params.Dc/Params.V0;
      dTdt=1-(Theta*V/(2*Params.Dc))^2;
      G=dTdt*Params.b/Theta;
  elseif(strcmpi(Flags.StateLaw,'Composite')) % Composite law [Kato & Tullis, 2003]. 
      Theta=exp((Psi-Params.f0)/Params.b)*Params.Dc/Params.V0;
      dTdt=exp(V/Params.V0)-(Theta*V/Params.Dc)*log(Theta*V/Params.Dc);
      G=dTdt*Params.b/Theta;
  elseif(strcmpi(Flags.StateLaw,'Nagata')) % Nagata law [Nagata et al., 2012].
      %Theta=exp((Psi-Params.f0)/Params.b)*Params.Dc/Params.V0;
      %dudt=
      %dTdt=1-(Theta*V/Params.Dc)-(Params.c*V/Params.b)*dudt;
      %G=dTdt*Params.b/Theta;
  end
  
  % Special case to avoid log(0).
  if V==0
      G=0;
  end
  
  % Optionally, add on a normal stress state evolution too [Linker & Dieterich, 1992].
  if(strcmpi(Flags.StateNorm,'on'))
      Theta=exp((Psi-Params.f0)/Params.b)*Params.Dc/Params.V0;
      dTdt=-(Params.alpha*Theta/(Params.b*(Params.N-ExtraP.P)))*ExtraP.dNdt;
      Gn=dTdt*Params.b/Theta;
      % Special case to avoid NaN.
      if Theta==0
          Gn=0;
      end
      G=G+Gn;
  end
  
  return
end


function residual = equilSnS(V,tauLock,Psi,Params,ExtraP,Flags)
  % Simple subroutine that computes the difference between applied fault
  % shear stress and fault strength.  Used to solve for V.
  
  % Compute the fault friction.
  %f = Params.a*log(V/Params.V0)+Psi; % Standard rate-and-state friction [Marone, 1998].
  f = Params.a*asinh(V/(2*Params.V0)*exp(Psi/Params.a)); % Regularized version handles small V better [Rice et al., 2001].
  
  % Optionally, include flash heating [Beeler et al., 2008].
  if(strcmpi(Flags.FlashHeat,'on'))
      fo=Params.a*asinh(Params.Vo/(2*Params.V0)*exp(Psi/Params.a));
      if(V>Params.Vo)
          f=(fo-Params.fw)*(Params.Vo/V)+Params.fw; % Eqn 5d.
          %f=Params.fw+(fo-Params.fw)/(1+(V/Params.Vo)*(1-exp(-(V/Params.Vo)^2))); % Eqn 7.
      end
  end
  
  % Compute the fault strength and shear stress.
  strength=f*(Params.N-ExtraP.P);
  stress=tauLock-Params.eta*V;
  
  % Return the difference between shear stress and strength.
  residual = stress-strength;
  
  return  
end


function [x,err]=hybrid_f0(func,a,b,atol,rtol)
  % Hybrid method solves func(x)=0 for some root x within (a,b).
  % Returns x, an estimate of root, with absolute error less than atol
  % or relative error less than rtol.
  
  % Function values at endpoints.
  fa=func(a);
  fb=func(b);
  
  % Make sure root is bracketed between given bounds.
  if( sign(fa)==sign(fb) || isnan(fa) || isnan(fb) )
    disp('error: root not bracketed or function is NaN at endpoint')
    fa
    fb
    x=NaN;
    err=NaN;
    return
  end
  
  % Set up secant method, using brackets to start.
  % Store old values as xold and fold, new ones as x and f
  xold=a;
  fold=fa;
  x=b;
  f=fb;
  
  % Prep for iterations.
  i=0;
  err=[];
  update='input';
  
  % Loop without end, since bisection is guaranteed to converge.
  while b-a>atol+rtol*abs(x) 
      
      % Formatted printing to check convergance.
      %fprintf('%6i %20.10f %20.10f %20.10f %s\n',n,a,x,b,update);
      
      % Iterate and add to end of vector.
      i=i+1; % iteration number
      err=[err b-a]; 
      
      % Calculate (tenative) secant update.
      dfdx=(f-fold)/(x-xold); % Approximation to df/dx.
      dx=-f/dfdx; % Update to x.
      xs=x+dx; % Secant update.
      
      % Determine if secant method will be used.
      if((xs<a)||(xs>b))
          % Update is outside (a,b).
          use_secant=false;
      else
          % Function value at secant update.
          fs=func(xs);

          % Calculate interval reduction factor = (old interval width)/(new interval width).
          if(sign(fs)==sign(fa))
              % Would update a=xs.
              IRF=(b-a)/(b-xs);
          else
              % Would update b=xs.
              IRF=(b-a)/(xs-a);
          end
          if(IRF<2)
              use_secant=false;
          else
              use_secant=true;
          end
      end
      
      % Store values for next iteration.
      xold=x;
      fold=f; 
      
      % Update.
      if(use_secant)
          update='secant';
          x=xs;
          f=fs;
      else
          update='bisection';
          x=(a+b)/2; % Midpoint.
          f=func(x); % Function value at midpoint.
      end
      
      % Update one endpoint based on sign of function value at updated x.
      if(sign(f)==sign(fa))
          a=x;
      else
          b=x;
      end
      
  end
  
end

