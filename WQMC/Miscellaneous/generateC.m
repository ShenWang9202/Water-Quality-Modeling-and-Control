function C = generateC(TargetedPipeID,LinkID,NumberofSegment4Pipes,Pipe_CStartIndex,JunctionCount,nColumn)
% Selection all elements except tanks and reserviors
% select all first to give it a try

[n,~] = size(TargetedPipeID);
TargetedPipeIndices = [];
for i = 1:n
    % find index according to ID.
    TargetedPipeIndices = [TargetedPipeIndices findIndexByID(TargetedPipeID{i},LinkID)];
end

totalNumSegment = sum(NumberofSegment4Pipes(TargetedPipeIndices));
nRow = JunctionCount + totalNumSegment;
rowIndex = 1:nRow;

columnIndex = [];
columnIndex = [columnIndex 1:JunctionCount];

[~,IntestedSize] = size(TargetedPipeIndices);
for j = 1:IntestedSize
    ind = TargetedPipeIndices(j);
    Indexrange = Pipe_CStartIndex(ind):Pipe_CStartIndex(ind) + NumberofSegment4Pipes(ind)-1;
    columnIndex = [columnIndex Indexrange];
end
valueVec = ones(1,nRow);
C = sparse(rowIndex,columnIndex,valueVec, nRow,nColumn);
end