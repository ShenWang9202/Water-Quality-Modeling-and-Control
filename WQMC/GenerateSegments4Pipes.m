function NumberofSegment4Pipes = GenerateSegments4Pipes(LinkLengthPipe,PipeIndex,d,Network)
[~,PipeCount] = size(PipeIndex);



switch Network
    case 1 % 3-node network
        NumberofSegment4Pipes = 150;%Constants4Concentration.NumberofSegment;
    case 4  % 8-node network
        NumberofSegment4Pipes = LinkLengthPipe/50; % ones(size(LinkLengthPipe))*3;
        NumberofSegment4Pipes = ceil(NumberofSegment4Pipes);
    case 7
        NumberofSegment4Pipes = LinkLengthPipe/50;
        NumberofSegment4Pipes = ceil(NumberofSegment4Pipes);
        NumberofSegment4Pipes(NumberofSegment4Pipes<10) = 10;
        NumberofSegment4Pipes(NumberofSegment4Pipes>200) = 200;
        
    case 9 % net3 network
        NumberofSegment4Pipes = LinkLengthPipe/10;
        
        NumberofSegment4Pipes(NumberofSegment4Pipes<20) = 20;
        NumberofSegment4Pipes(NumberofSegment4Pipes>500) = 500;
        NumberofSegment4Pipes(1:3) = 90;
        
        % set number of segment according to velocity
        LinkVelocity = d.getBinComputedLinkVelocity;
        PipeVelocity = LinkVelocity(:,PipeIndex);
        maxPipeVelocity = max(PipeVelocity);
        doubledIndex = find(maxPipeVelocity > 1 & maxPipeVelocity <= 2);
        NumberofSegment4Pipes(doubledIndex) = NumberofSegment4Pipes(doubledIndex) * 1.5;
        doubledIndex = find(maxPipeVelocity > 2 & maxPipeVelocity <= 4);
        NumberofSegment4Pipes(doubledIndex) = NumberofSegment4Pipes(doubledIndex) * 2;
        doubledIndex = find(maxPipeVelocity > 4);
        NumberofSegment4Pipes(doubledIndex) = NumberofSegment4Pipes(doubledIndex) * 2.5;
        
        % set number of segment accroding to our interesent (usally we need to improve the number of segment of pipes where booster is installed around)
        
        tempID = d.getLinkNameID;
        tempID = tempID(PipeIndex);
        InterestedID = {'245','247','249','251','257','261','269',...
            '263','271','273','275','281','283','285','289',...
            'P87','P91','P93','295','281','283','285'
            };%LinkID';
        InterestedID = unique(InterestedID);
        IDcell = tempID;
        [~,n] = size(InterestedID);
        InterestedPipeIndices = [];
        for i = 1:n
            % find index according to ID.
            InterestedPipeIndices = [InterestedPipeIndices findIndexByID(InterestedID{i},IDcell)];
        end
        
        tempIndex = find(NumberofSegment4Pipes(InterestedPipeIndices) < 100);
        NumberofSegment4Pipes(InterestedPipeIndices(tempIndex)) = 100;
        NumberofSegment4Pipes = ceil(NumberofSegment4Pipes);
        
        
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