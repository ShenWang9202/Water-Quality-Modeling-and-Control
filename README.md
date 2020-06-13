# Water-Quality-Modeling-and-Control

This is the source code for our paper "How Effective is Model Predictive Control in Real-Time Water Quality Regulation? State-Space Modeling and Scalable Control"

Abstract: Real-time water quality control (WQC) in water distribution networks (WDN), the problem of regulating disinfectant levels, is challenging due to lack of (i) a proper
control-oriented modeling considering complicated components (junctions, reservoirs, tanks, pipes, pumps, and valves) for water quality modeling in WDN and (ii) a corresponding scalable control algorithm that performs real-time water quality regulation. In this paper, we solve WQC problem by (a) proposing a novel state-space representation of the WQC problem that provides explicit relationship between inputs (chlorine dosage at booster stations) and states/outputs (chlorine concentrations in the entire network) and (b) designing a highly scalable model predictive control (MPC) algorithm that showcases fast response time and resilience against some sources of uncertainty.

This model is based on EPANET-Matlab-Toolkit (Version  2.1.8.1) which is a Matlab class for EPANET water distribution simulation libraries, please install this toolkit before simulation, see https://github.com/OpenWaterAnalytics/EPANET-Matlab-Toolkit#How-to-use-the-Toolkit for details.

The functions are in WQCM fold, and click "run" in Matlab after loading main.m
We now only give two simple examples, but our code is general for all kinds of networks. The readers are welcome to extend their own examples.

The networks in case studies are located in network/ folder

The Rule-based Control simulation are in RuleBasedControl.m, and this is only an example for three-node networks.
