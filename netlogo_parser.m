%% NetLogo Batch Run Parser
%   by Derek Hollenbeck
clc
clear

% function inputs
analysisType = 1;
fn = 'test.csv';

switch analysisType
    case 1    
        deliminator = ',';
        temp = importdata(fn,deliminator);
    otherwise
        display('Error')
end