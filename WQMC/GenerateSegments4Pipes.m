function NumberofSegment4Pipes = GenerateSegments4Pipes(LinkLengthPipe,PipeIndex,d,Network)
[~,PipeCount] = size(PipeIndex);

NumberofSegment4Pipes = 80 * ones(PipeCount,1); % defaultly, it should be 80;


switch Network
    case 1 % 3-node network
        NumberofSegment4Pipes = 150;%Constants4Concentration.NumberofSegment;
    case 4  % 8-node network  
        NumberofSegment4Pipes = LinkLengthPipe/50; % ones(size(LinkLengthPipe))*3; 
        NumberofSegment4Pipes = ceil(NumberofSegment4Pipes);
    case 7
        NumberofSegment4Pipes = LinkLengthPipe/20;
        NumberofSegment4Pipes = ceil(NumberofSegment4Pipes);
        NumberofSegment4Pipes(NumberofSegment4Pipes<200) = 200;
        
    case 9 % net3 network
        extraSeg = 10;
        for i = 1:PipeCount
            if(LinkLengthPipe(i) <= 200)
                NumberofSegment4Pipes(i) = 15 + extraSeg;
            end
            if(LinkLengthPipe(i) > 200 && LinkLengthPipe(i) <= 500)
                NumberofSegment4Pipes(i) = 20 + extraSeg;
            end
            if(LinkLengthPipe(i) > 500 && LinkLengthPipe(i) <= 1000)
                NumberofSegment4Pipes(i) = 50;
            end
            if(LinkLengthPipe(i) > 1000 && LinkLengthPipe(i) <= 2000)
                NumberofSegment4Pipes(i) = 80;
            end
            if(LinkLengthPipe(i) > 2000 && LinkLengthPipe(i) <= 3000)
                NumberofSegment4Pipes(i) = 100;
            end
            if(LinkLengthPipe(i) > 3000 && LinkLengthPipe(i) <= 5000)
                NumberofSegment4Pipes(i) = 150;
            end
            if(LinkLengthPipe(i) > 5000 && LinkLengthPipe(i) <= 10000)
                NumberofSegment4Pipes(i) = 400;
            end
            
            if(LinkLengthPipe(i) > 10000 && LinkLengthPipe(i) <= 30000)
                NumberofSegment4Pipes(i) = 800;
            end
            if(LinkLengthPipe(i) > 30000 && LinkLengthPipe(i) <= 50000)
                NumberofSegment4Pipes(i) = 2000;
            end
            
            if(LinkLengthPipe(i) > 50000)
                NumberofSegment4Pipes(i) = 3000;
            end
        end
        
        NumberofSegment4Pipes = LinkLengthPipe/10;
        NumberofSegment4Pipes = ceil(NumberofSegment4Pipes);
        NumberofSegment4Pipes(NumberofSegment4Pipes<150) = 150;
        NumberofSegment4Pipes(1:3) = 1000;
        
        
        % allResult = d.getComputedHydraulicTimeSeries;
        % Velocity = allResult.Velocity; % volocity for all pipes at all times
        % maxVelocity = max(Velocity);
        % maxVelocity = maxVelocity(:,PipeIndex);
        %
        % minVelocity = min(Velocity);
        % minVelocity = minVelocity(:,PipeIndex);
        %
        % Expectedt = 10;
        % NumberofSegment4Pipes = LinkLengthPipe./minVelocity./Expectedt;
        % NumberofSegment4Pipes = LinkLengthPipe./maxVelocity./Expectedt;
        
        % NumberofSegment4Pipes = LinkLengthPipe/2;
        % NumberofSegment4Pipes = ceil(NumberofSegment4Pipes);
        % NumberofSegment4Pipes(NumberofSegment4Pipes<80) = 80;
        % NumberofSegment4Pipes(1:3) = 1000;
        %
        %NumberofSegment = 150;%Constants4Concentration.NumberofSegment;
        %NumberofSegment4Pipes = NumberofSegment * ones(PipeCount,1); % defaultly, it should be NumberofSegment;
end