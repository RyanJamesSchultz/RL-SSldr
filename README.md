# RL-SSldr

I present a Matlab-based enviroment, RL-SSldr that uses reinforcement learning to stabilize a spring-slider.  This is a collection of codes applied in a study about the same topic [Schultz, 2024].

These files are a collection of Matlab classes, programs, and scripts.  The core files are mentioned here.  The file script_TD3.m will train a reinfocement learning agent using the Twin Delayed Deep Deterministic (TD3) approach to reinforcement learning.  The file SpringSlider.m numerically simulates the spring-slider via a time-adaptive Runge-Kutta solver.  The file RL_SSenv.m is a wrapper class for the spring-slider, to cast it into Matlab's reinforcement learning environment class.  The F*.m files were used to create the figures used in the accompanying study [Schultz, 2024].  The sub-directory 'TrainedAgents' is a collection of failed training attempts to guide readers through my thought process toward the finalized training routine.

References: 
            
            R. Schultz, (2024)
            How to tame an earthquake (analogue)
            submitted to Nature, xx, XXX.
            doi: xyz.
            

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details: http://www.gnu.org/licenses/
