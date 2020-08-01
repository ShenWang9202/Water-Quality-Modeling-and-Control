function [Index,isPipe] =  findIndexofLastorFirstSegment(ind,IndexInVar,flipped)
basePipeIndex = min(IndexInVar.PipeIndex);
BasePipe_CIndex = min(IndexInVar.Pipe_CIndex);
basePumpIndex = min(IndexInVar.PumpIndex);
BasePump_CIndex = min(IndexInVar.Pump_CIndex);
isPipe = ispipe(ind,IndexInVar.PipeIndex);
if(isPipe) % contribution is from pipe
    howmany = ind - basePipeIndex +1;
    if(flipped)
        Index =  (howmany - 1) * Constants4Concentration.NumberofSegment + BasePipe_CIndex;
    else
        Index =  howmany * Constants4Concentration.NumberofSegment + BasePipe_CIndex - 1;
    end
    
else % pump or valves
    Index = ind - basePumpIndex + BasePump_CIndex;
end
end

function result =  ispipe(ind,PipeIndex)
result = true;
if(ind>max(PipeIndex))
    result = false;
end
end