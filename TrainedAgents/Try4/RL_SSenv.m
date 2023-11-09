classdef RL_SSenv < rl.env.MATLABEnvironment
    % SpringSlider_Environment: Reinforcement learning environment for 
    % stabilizing a spring-slider system.
    % 
    % Written by Ryan Schultz.
    
    %%%% Properties (set properties' attributes accordingly)
    properties
        % Specify and initialize environment's necessary properties.
        
        % Spring slider input structures.
        P0 = struct(); % For priming the fault.
        P1 = struct(); % First step inputs: i.e., following fault priming.
        Ps = struct(); % Current state's parameters, used as input for next step.
        
        % Spring slider output structures.
        O1 = struct(); % Output parameters, following fault priming.
        Os = struct(); % Most recent step appended to the output structure.
        Oc = struct(); % Last step's output (non-appended).
        
        % Spring slider flags.
        F = struct('Tsteps','adaptive', 'StateLaw','slip', 'Injection','on', 'StateNorm','on', 'FlashHeat','off');
        
        % Spring slider solver parameters.
        S0 = struct('tol',1e-4, 'dt',1e+0, 'dtmax',1e+7, 'safety',0.9);
        Ss = struct('tol',1e-8, 'dt',1e-6, 'dtmax',1e+2, 'safety',0.8);
        
        % Logging step times and rewards.
        Te=0;
        Re=0;
        
        % Derived constant.
        kcr=0;
        V1=0;
        mu1=0;
        dP1=0;
        N1=0;
        Nc=0;
        
        % Flag for the flag reached at simulation end.
        End_type='continue';
        
    end
    
    properties
        % Initialize system state.
        State = zeros(3,1);
    end
    
    properties(Access = protected)
        % Initialize internal flag to indicate episode termination.
        IsDone = false;
    end
    
    %%%% Necessary Methods
    methods              
        % Contructor method creates an instance of the environment
        function this = RL_SSenv()
            
            % Initialize Observation settings.
            ObservationInfo = rlNumericSpec([3 1]);
            ObservationInfo.Name = 'Spring Slider State';
            ObservationInfo.Description = 'Fault Slip Rate log10(m/s); Empirical Fault Friction (-); Differential Pore Pressure (MPa)';
            ObservationInfo.LowerLimit=[-Inf;   0; -Inf];
            ObservationInfo.UpperLimit=[   2; Inf;  Inf];
            
            % Initialize Action settings.
            ActionInfo = rlNumericSpec([2 1]);
            ActionInfo.Name = 'Operator Action';
            ActionInfo.Description = 'Injection Pressure Change (MPa); Absolute Injection Pressure Rate Change log10(MPa/s)';
            ActionInfo.LowerLimit=[-2;-9];
            ActionInfo.UpperLimit=[+2;+9];
            
            % Implement built-in functions of RL environment.
            this = this@rl.env.MATLABEnvironment(ObservationInfo,ActionInfo);
            
            % Initialize property values.
            InitializeValues(this);
            PrimeFault(this);
            
        end
        
        % Initialize the internal variables to physically meaningful values.
        function InitializeValues(this)
            
            % Some constants.
            c = 3.5;                   % S-wave speed (km/s).
            rho = 2.7;                 % Density (g/cm³).
            oneyear = 60*60*24*365.25; % Seconds in a year.
            tmax=23*oneyear;           % Total simulation time (s).
            %tmax=23.70207205492*oneyear;      % Total simulation time (s) - gets to nucleation or co-seismic phases.
            %tmax=23.702072054929955*oneyear;  % Total simulation time (s) - gets to immediate post-seismic phase.
            %tmax=23.7021868*oneyear;          % Total simulation time (s) - gets to later post-seismic phase.
            %tmax=26*oneyear;                  % Total simulation time (s) - gets to later inter-seismic phase.
            
            
            % Input parameters.
            this.P0 = struct('f0',0.6, 'V0',1e-16, 'a',1e-3, 'b',5e-3, 'Dc', 1e-5, ...
                             'c',1, 'alpha',0.4, 'Vo',0.3, 'fw',0.2, ...
                             'eta',rho*c/2, 'k',(30*1000)/(1*1000), 'N',95, ...
                             'tmax',tmax, 't',[0 tmax+1], ...
                             'dtaudt',(0.1/oneyear), 'P',[80 80], 'dNdt',[0 0], ...
                             'D0',0, 'tau0',0.9*0.6*(95-80), 'Psi0',0.6 );
            
            % Derived constants.
            this.kcr = (this.P0.N-this.P0.P(1))*(this.P0.b-this.P0.a)/this.P0.Dc; % Critical stiffness (neglecting radiation-damping) (MPa/m).
            this.Nc = this.P0.k*this.P0.Dc/(this.P0.b-this.P0.a);                 % Critical normal stress (MPa).
            
        end
        
        % Prime the fault to an initial state.
        function PrimeFault(this)
            
            % Run the spring slider, with initial parameters.
            [O]=SpringSlider(this.P0,this.S0,this.F);
            
            % Update the internal variables.
            this.P1=this.P0;
            this.P1.D0=O.D(end);
            this.P1.Psi0=O.Psi(end);
            this.Ps=this.P1;
            this.O1=O;
            this.Os=O;
            this.Oc=O;
            this.V1=(O.V(end));
            this.mu1=(O.tau(end)/O.norm(end));
            this.N1=O.norm(end);
            this.Te=this.P1.tmax;
            
            % Update the external variables.
            InitialObservation = [log10(O.V(end)); this.mu1; this.dP1];
            this.State = InitialObservation;
            
        end
        
        % Reset environment to initial state and output initial observation
        function InitialObservation = reset(this)
            
            % Change the iterated internal variable back to the 'primed' values.
            this.Ps=this.P1;
            this.Os=this.O1;
            this.Oc=this.O1;
            
            % Reset the external state variables.
            InitialObservation = [log10(this.V1); this.mu1; this.dP1];
            this.State = InitialObservation;
            
            this.Te=this.P1.tmax;
            this.Re=0;
            
            % (optional) use notifyEnvUpdated to signal that the 
            % environment has been updated (e.g. to update visualization)
            notifyEnvUpdated(this);
        end
        
        % Apply fault dynamics given the input action.
        function [Observation,Reward,IsDone,LoggedSignals] = step(this,Action)
            LoggedSignals = [];
            
            % Unpack the input action into the internal variables.
            updateInternalAction(this,Action);
            
            % Run the spring slider, with the input action.
            [O]=SpringSlider(this.Ps,this.Ss,this.F);
            
            % Get reward and check for terminal condition(s).
            [Reward,IsDone,end_type] = RewardFxn(this,O,this.Os);
            this.End_type=end_type;
            
            % Update internal/external system state.
            updateInternalState(this,O);
            dP=(this.P1.N-O.norm(end))-this.P1.P(1);
            Observation = [log10(O.V(end)); O.tau(end)/O.norm(end); dP];
            this.State = Observation;
            
            % Record logged signals?
            this.Te=[this.Te,this.Ps.tmax];
            this.Re=[this.Re,Reward];
            
            % (optional) use notifyEnvUpdated to signal that the 
            % environment has been updated (e.g. to update visualization)
            notifyEnvUpdated(this);
        end
        
        % Prime the fault with an additional sequence of user-input actions.
        function append(this,StepHistory)
            
            % First reset the environment.
            this.reset();
            
            % Apply the sequence of actions given as steps.
            for i=1:length(StepHistory)
                action=StepHistory(i).Action{1}; % Step history is a strucutre consistent with the Matlab rlReplayMemory class.
                this.step(action);
            end
            
            % Modify the internal variables.
            this.P1=this.Ps;
            this.O1=this.Os;
            
            % Modify the starting values.
            this.V1=this.Os.V(end);
            this.mu1=(this.Os.tau(end)/this.Os.norm(end));
            dP=(this.P1.N-this.Os.norm(end))-this.P1.P(1);
            this.dP1=dP;
            this.N1=this.Os.norm(end);
            
            % Update the external variables.
            InitialObservation = [log10(this.V1); this.mu1; this.dP1];
            this.State = InitialObservation;
            
            this.Te=this.P1.tmax;
            this.Re=0;
        end
        
    end
    %%%% Optional Methods (set methods' attributes accordingly)
    methods               
        
        % Helper method to update the internal variables based on the Agent's chosen action.
        function updateInternalAction(this,Action)
            
            % Unpack the action vector.
            dP=Action(1);
            dPdt=10.^Action(2);
            T=this.Ps.tmax;
            P=this.Ps.P(end);
            
            % Ensure that actions are plausibly bounded.
            dPdt=max([1e-9   dPdt]); dPdt=min([1e+9 dPdt]);
            dP=  max([-2   dP]);     dP=  min([+2    dP]);
            
            % Get the time interval to take the action over.
            if(dP==0)
                dt=3600;
                dPdt=0;
            else
                dt=abs(dP)/dPdt;
            end
            if(dt<1e-3)
                dt=1e-3;
            end
            
            % Prep for the next slip.
            this.Ps.tmax = T+dt;  % Total simulation time (s).
            this.Ps.t=[T, T+dt, T+dt+1];  % Injection time vector (s).
            this.Ps.P=[P, P+dP, P+dP  ];  % Pressure time-series (MPa).
            this.Ps.dNdt=diff(this.Ps.P()-this.Ps.P())./diff(this.Ps.t); this.Ps.dNdt=[this.Ps.dNdt, this.Ps.dNdt(end)]; % Differential normal stress time-series (MPa/s).
            
            this.Ss.dt=min([1e-6 dt/5]);
        end
        
        % Helper method to update the internal variables based on the SpringSlider output data structure.
        function updateInternalState(this,SSout)
            
            % Update input state from the last slip.
            this.Ps.D0=SSout.D(end);
            this.Ps.Psi0=SSout.Psi(end);
            
            % Append output from last slip.
            this.Os.t=   [this.Os.t;    SSout.t   ];
            this.Os.D=   [this.Os.D;    SSout.D   ];
            this.Os.V=   [this.Os.V;    SSout.V   ];
            this.Os.tau= [this.Os.tau;  SSout.tau ];
            this.Os.norm=[this.Os.norm; SSout.norm];
            this.Os.Psi= [this.Os.Psi;  SSout.Psi ];
            this.Os.dt=  [this.Os.dt;   SSout.dt  ];
            this.Oc=SSout;
        end
        
        % Helper method that will return the reining pressure rate, given the current state.
        function [dPdt]=ReiningAction(this)
            
            % Get the required variables.
            V0=this.P0.V0;
            f0=this.P0.f0;
            Dc=this.P0.Dc;
            b=this.P0.b;
            alpha=this.P0.alpha;
            dTdt_inf=this.P0.dtaudt;
            k=this.P0.k;
            
            % Get some more variables.
            V=this.Oc.V(end);
            N=this.Oc.norm(end);
            Psi=this.Oc.Psi(end);
            Theta=exp((Psi-f0)/b)*Dc/V0;
            dTdt=dTdt_inf-(k*V);
            
            % Check for state evolution law.
            if(strcmpi(this.F.StateLaw,'aging'))
                g1=1-(Theta*V/Dc);
            elseif(strcmpi(this.F.StateLaw,'slip'))
                g1=(-Theta*V/Dc)*log(Theta*V/Dc);
            end
            
            % Generate the best guess, based on numerical estimation of normal stressing rate (Eqn S1.8).
            dNdt=(N*g1*b)/(alpha*Theta)-(dTdt/alpha);
            dPdt=log10(abs(dNdt)); % Returned in the action-space format.
            
        end
        
        % Visualization method
        function plot(this)
            
            % Predefine some values.
            oneyear = 60*60*24*365.25; % Seconds in a year.
            I=(this.Os.t>this.O1.t(end));
            t=this.Os.t(I);
            
            % Failure bounds.
            Vfail=2e-1;
            Vslow=1e-5;
            
            % Get the required variables.
            V0=this.P0.V0;
            f0=this.P0.f0;
            Dc=this.P0.Dc;
            b=this.P0.b;
            alpha=this.P0.alpha;
            dTdt_inf=this.P0.dtaudt;
            k=this.P0.k;
            
            % Get some more variables.
            V=this.Os.V;
            N=this.Os.norm;
            Psi=this.Os.Psi;
            Theta=exp((Psi-f0)/b)*Dc/V0;
            dTdt=dTdt_inf-k*V;
            
            % Check for state evolution law.
            if(strcmpi(this.F.StateLaw,'aging'))
                g1=1-(Theta.*V/Dc);
            elseif(strcmpi(this.F.StateLaw,'slip'))
                g1=(-Theta.*V/Dc).*log(Theta.*V/Dc);
            end
            
            % Generate the best guess, based on numerical estimation of normal stressing rate (Eqn S1.8).
            dNdt=(N.*g1.*b)./(alpha*Theta)-(dTdt/alpha);
            dPdt=-dNdt; % Returned in the action-space format.
            
            % Plot.
            figure(1),clf
            
            ax1=subplot(5,2,1);
            semilogy(this.O1.t/oneyear,this.O1.V); hold on;
            semilogy(xlim(),Vfail*[1 1],':k');
            semilogy(xlim(),Vslow*[1 1],':k');
            xlabel('Time (years)');
            ylabel('Slip velocity (m/s)');
            
            ax2=subplot(5,2,2);
            semilogy(t-t(1),this.Os.V(I)); hold on;
            semilogy(xlim(),Vfail*[1 1],':k');
            semilogy(xlim(),Vslow*[1 1],':k');
            xlabel('Time (s)');
            ylabel('Slip velocity (m/s)');
            ylim([1e-6 1e0]);
            
            ax3=subplot(5,2,3);
            plot(this.O1.t/oneyear, this.O1.D*100);
            xlabel('Time (years)');
            ylabel('Slip displacement (cm)');
            
            ax4=subplot(5,2,4);
            plot(t-t(1), this.Os.D(I)*100);
            xlabel('Time (s)');
            ylabel('Slip displacement (cm)');
            
            ax5=subplot(5,2,5);
            plot(this.O1.t/oneyear,this.O1.tau, 'DisplayName','Shear Stress'); hold on;
            plot(this.O1.t/oneyear,this.O1.norm,'DisplayName','Normal Stress');
            plot(xlim(),this.Nc*[1 1],'--k','DisplayName','Critical Normal Stress');
            xlabel('Time (years)');
            ylabel('Fault stress (MPa)');
            legend('Location','best');
            
            ax6=subplot(5,2,6);
            plot(t-t(1),this.Os.tau(I),'DisplayName','Shear Stress'); hold on;
            plot(t-t(1),this.Os.norm(I),'DisplayName','Normal Stress');
            plot(xlim(),this.Nc*[1 1],'--k','DisplayName','Critical Normal Stress');
            xlabel('Time (s)');
            ylabel('Fault stress (MPa)');
            legend('Location','best');
            
            ax7=subplot(5,2,7);
            %Theta=exp((this.O1.Psi-this.P0.f0)/this.P0.b)*this.P0.Dc/this.P0.V0;
            Psi=this.O1.Psi;
            semilogy(this.O1.t/oneyear,Psi);
            xlabel('Time (years)');
            ylabel('Fault state \Psi (-)');
            
            ax8=subplot(5,2,8);
            %Theta=exp((this.Os.Psi-this.P0.f0)/this.P0.b)*this.P0.Dc/this.P0.V0;
            Psi=this.Os.Psi;
            plot(t-t(1),Psi(I));
            xlabel('Time (s)');
            ylabel('Fault state \Psi (-)');
            
            ax9=subplot(5,2,9);
            semilogy(this.Os.t(~I)/oneyear,abs(dPdt(~I)));
            xlabel('Time (years)');
            ylabel('Reining Pressure Rate (MPa/s)');
            
            ax10=subplot(5,2,10);
            semilogy(t-t(1),abs(dPdt(I)));
            xlabel('Time (s)');
            ylabel('Reining Pressure Rate (MPa/s)');
            
            %ax9=subplot(5,2,9);
            %semilogy(this.O1.t/oneyear,this.O1.dt);
            %xlabel('Time (years)');
            %ylabel('\Deltat (s)');
            
            %ax10=subplot(5,2,10);
            %semilogy(t-t(1),this.Os.dt(I));
            %xlabel('Time (s)');
            %ylabel('\Deltat (s)');
            
            linkaxes([ax1 ax3 ax5 ax7 ax9 ],'x');
            linkaxes([ax2 ax4 ax6 ax8 ax10],'x');
            
            figure(2); clf;
            i=find(I,true,'first');
            Vss = logspace(-12,0,100);
            fss = fsteadystate(this,Vss);
            fsb = fstablebound(this,Vss);
            semilogx(this.Os.V(I),this.Os.tau(I)./this.Os.norm(I),'-b','DisplayName','f'); hold on;
            semilogx(this.Os.V(i),this.Os.tau(i)./this.Os.norm(i),'ob','HandleVisibility','off');
            semilogx(Vss,fss,'--k','DisplayName','fss');
            semilogx(Vss,fsb,'-r','DisplayName','fsb');
            semilogx(Vfail*[1 1],ylim(),':k','HandleVisibility','off');
            semilogx(Vslow*[1 1],ylim(),':k','HandleVisibility','off');
            xlabel('Fault slip velocity (m/s)');
            ylabel('Friction coefficient');
            legend('Location','best');
            ylim([min(fss) this.P0.f0]);
            grid on;
            
            figure(3); clf;
            bar(0:length(this.Re)-1,this.Re); hold on;
            plot(0:length(this.Re)-1,cumsum(this.Re),'-o')
            xlabel('Step number'); ylabel('Reward');
            
            % Update the visualization
            envUpdatedCallback(this)
        end
        
        % Helper method to determine (approximate) steady-state values.
        function fss = fsteadystate(this,V)
            fss = this.P0.f0+(this.P0.a-this.P0.b)*log(V/this.P0.V0);
        end
        
        % Helper method to determine (approximate) stability boundary [Rice & Gu, 1983].
        function fsb = fstablebound(this,V)
            % Rice & Gu. (1983). Earthquake aftereffects and triggered seismic phenomena. Pure and Applied Geophysics, 121, 187-219, doi: 10.1007/BF02590135
            Vs=this.P0.V0;
            fs=this.P0.f0;
            Vo=this.P0.dtaudt/this.P0.k;
            lambda=(this.P0.b-this.P0.a)/this.P0.a; % Eqn 22.
            vo=Vo/Vs;
            phi=log(V/Vo);
            
            Fsb=1-lambda*(phi+vo*exp(-phi)-1); % Eqn 29.
            %fsb=1-lambda*(phi+(Vo^2./(V*Vs))-1);
            
            fsb=this.P0.a*(Fsb+fs/this.P0.a); % Fig 10 & Eqn 27.
        end
        
    end
    
    methods (Access = protected)
        % (optional) update visualization everytime the environment is updated 
        % (notifyEnvUpdated is called)
        function envUpdatedCallback(this)
        end
    end
end
