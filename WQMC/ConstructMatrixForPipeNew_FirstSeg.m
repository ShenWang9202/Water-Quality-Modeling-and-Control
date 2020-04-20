function [A_Pipe_New,B_Pipe_New] = ConstructMatrixForPipeNew_FirstSeg(EnergyMatrixPipe,ElementCount,aux,A_P,UpstreamNode_Amatrix,UpstreamNode_Bmatrix,B_P)

NumberofSegment = aux.NumberofSegment;
%find the Index of Node at both end of that link
IndexofNode_pipe =  findIndexofNode_Link(EnergyMatrixPipe);
% Since all these indexes in IndexofNode_pipe are either junction,
% reservoir, or tanks, so the corresponding Concerntration Index is exactly
% the same. Hence, IndexofNode_pipe is the Concerntration Index we are
% looking for.

PipeCount = ElementCount.PipeCount;
for i = 1:PipeCount
    %here, need to use the index of node connecting the first segement
    UpStreamNodeIndexOfPipe = IndexofNode_pipe(i,1);
    FirstSegmentIndexofPipe = ((i-1)*NumberofSegment + 1);
    A_P(FirstSegmentIndexofPipe,:) = UpstreamNode_Amatrix(UpStreamNodeIndexOfPipe,:) ;
    B_P(FirstSegmentIndexofPipe,:) = UpstreamNode_Bmatrix(UpStreamNodeIndexOfPipe,:) ;
end
A_Pipe_New = A_P;
B_Pipe_New = B_P;