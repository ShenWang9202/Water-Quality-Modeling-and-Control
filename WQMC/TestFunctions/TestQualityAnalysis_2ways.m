% Use two different ways to test quality analysis

% Method 1: The reaction formula is written in .inp files
% (independent from .inp file)

TestQualityAnalysis_3node_inp

pause

% Method 2: USE LoadMSXFile command, the reaction formula is in .msx file
% (independent from .inp file)
TestLoadMSXFile_3node_inp


% normal the second way is better, since it can be applicable to
% multispecies directly, for the first method, it's hard to combine every
% formula into the .inp file

% Note that the Kb in .inp file is in mg/day
% While the Kb in .msx is in mg/min, we need to convert

