function x_estimated = Hack_x_estimated_ByID(x_estimated,Struct4Hack)
% See Variable_Symbol_Table2 for the indices to verify

PipeID_Cell = Struct4Hack.PipeID_Cell;
Sudden_Concertration = Struct4Hack.Sudden_Concertration;
NumberofSegment = Struct4Hack.NumberofSegment;
Pipe_CIndex = Struct4Hack.Pipe_CIndex;
PipeID = Struct4Hack.PipeID;
JunctionID_Cell = Struct4Hack.JunctionID_Cell;
JunctionID = Struct4Hack.JunctionID;

% For pipes
[~,n] = size(PipeID_Cell);
BaseCindeofPipe = min(Pipe_CIndex);
for i = 1:n
    % find PipeIndex according to ID.
    pipeIndex = findIndexByID(PipeID_Cell{i},PipeID);
    % find CIndexofPipe 
    CIndexofPipe = findCIndexofPipe(pipeIndex,BaseCindeofPipe,NumberofSegment);
    % set the value to 
    x_estimated(CIndexofPipe) = Sudden_Concertration;
end

% For junctions
[~,n] = size(JunctionID_Cell);
for i = 1:n
    % find PipeIndex according to ID.
    JunctionIndex = findIndexByID(JunctionID_Cell{i},JunctionID);
    % set the value to 
    x_estimated(JunctionIndex) = Sudden_Concertration;
end


end