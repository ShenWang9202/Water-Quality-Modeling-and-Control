function index = findIndexByID(locationID,NodeID)
    index = find(strcmp(locationID,NodeID));
    %strmatch(locationID,NodeID,'exact');
end