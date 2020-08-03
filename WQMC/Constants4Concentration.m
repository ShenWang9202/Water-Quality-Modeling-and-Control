classdef Constants4Concentration
    properties( Constant = true )
        Network = 9;% use 1 4 7 9 % Don't use case 2
        % Only do water quality simulation using LDE model and compare it
        % with EPANET (set ONLY_COMPARE variable as 1, otherwise, set it as 0)
        ONLY_COMPARE = 0;
        
        
        SimutionTimeInMinute = 4*60; 
        %SimutionTimeInMinute = 4*24*60; % Simulate Net1 for 4 day
        SimutionTimeInMinute4RBC = 24*60;  
        % Interval (in minutes) of injecting chlorin from boosters (must be a factor or divisor of Hq_min)
        T_booster_min = 1;
        % Control Horizen (in minutes) of MPC algorithm (must be a factor or divisor of Hydraulic Time Step, which is 60 minutes defaultly in our case studies)
        Hq_min = 5;
        % How many segements of a pipe.
        NumberofSegment = 100;
        
        % The price of injecting chlorine,
        Price_Weight = 0.001;
        % The setpoint or reference of chlorin concentration in WDNs (any value between 0.4~4mg/L);
        reference = 2;
        % Q coefficent is an index of pushing the concentration in links
        % and nodes to the reference value
        Q_coeff = 50;
        % R coefficent is an index of controlling the smoothness of control
        % actions
        R_coeff = 1;


        DayInSecond = 86400;
        MinInSecond = 60;
        Gallon2Liter = 3.78541;
        FT2Inch = 12;
        pi = 3.141592654;
        GPMperCFS= 448.831;
        AFDperCFS= 1.9837;
        MGDperCFS= 0.64632;
        IMGDperCFS=0.5382;
        LPSperCFS= 28.317;
        M2FT = 3.28084;
        LPS2GMP = 15.850372483753;
        LPMperCFS= 1699.0;
        CMHperCFS= 101.94;
        CMDperCFS= 2446.6;
        MLDperCFS= 2.4466;
        M3perFT3=  0.028317;
        LperFT3=   28.317;
        MperFT=    0.3048;
        PSIperFT=  0.4333;
        KPAperPSI= 6.895;
        KWperHP=   0.7457;
        SECperDAY= 86400;
        SpecificGravity = 1;
    end
end
