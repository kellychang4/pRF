function create_model(modelName, params, funcOf, equation)
% create_model(modelName, params, funcOf, equation)
%
% Inputs:
%   <No Arg>            Creates a template model function script for manual
%                       modifications, saved as 'MODEL.m' in current
%                       working directory
%   modelName           Name of the model function, is possible to specify
%                       file path as well if desired, string
%   params              Parameter(s) of the model, string or cell of
%                       strings for multiple parameters
%   funcOf              Parameter(s) the model is a function of, string or
%                       cell of string for multiple function of parameters
%   equation            Model equation with parameters specified as
%                       'p.<params>' and function of parameters specified
%                       as 'f.<funcOf>', string (see Example)
%
% Example:
% modelName = 'Gaussian2D';
% params = {'xMu', 'yMu', 'xSigma', 'ySigma'};
% funcOf = {'x', 'y'};
% equation = 'exp(-((((f.x-p.xMu).^2)/(2*p.xSigma^2)) + (((f.y-p.yMu).^2)/(2*p.ySigma^2))))';
%
% createModel(modelName, equation, params, funcOf);

% Written by Kelly Chang - October 11, 2016

%% Writing Model Function

if nargin < 1
    txt{1} = 'function [out] = [MODEL](params, funcOf)\n';
    txt{end+1} = '%% [out] = [MODEL](params, funcOf)\n';
    txt{end+1} = '%% \n%% Inputs:\n';
    txt{end+1} = '%%   <No Arg>\t\tNo arguments, will return a structure containing the\n%%\t\t\t\t\trequired field names for ''params'' and ''funcOf''\n';
    txt{end+1} = '%%   params\t\t\tA structure that specifes the parameters of the model:\n';
    txt{end+1} = '%%      <params>\n';
    txt{end+1} = '%%   funcOf\t\t\tA structure that speficies the model function of\n%%\t\t\t\t\tparameters:\n';
    txt{end+1} = '%%      <funcOf>\n';
    txt{end+1} = '%% \n%% Output:\n';
    txt{end+1} = '%%    out\t\t\tOutput of the model function from the given parameters\n%%\t\t\t\t\treported as a column\n\n';
    txt{end+1} = sprintf('%%%% Written by [NAME] - %s\n', datestr(now, 'mmmm dd, yyyy'));
    txt{end+1} = '\n%%%% Equation\n\n';
    txt{end+1} = 'if nargin < 1\n\tout.params = {''''};\n\tout.funcOf = {''''};\n';
    txt{end+1} = 'else\n\tout = [EQUATION];\n\tout = out(:);\nend\n';
    
    fid = fopen('MODEL.m', 'w+');
    for i = 1:length(txt)
        fprintf(fid, txt{i});
    end
    fclose(fid);
    
    %% Output
    
    fprintf('Saved As: MODEL.m\n');
else
    %% Input Control
    
    if ischar(params)
        params = {params};
    end
    
    if ischar(funcOf)
        funcOf = {funcOf};
    end
    
    %% Identify Variable Names
    
    vars = {params funcOf}; % all variables
    
    tmp = cellfun(@(x,y) strcat(x,y), {'p.', 'f.'}, vars, 'UniformOutput', false);
    matchVars = [tmp{:}]; % matching variables in equation
    
    tmp = cellfun(@(x,y) strcat(x,y), {'params.', 'funcOf.'}, vars, 'UniformOutput', false);
    modelVars = [tmp{:}]; % actual model variables in final equation
    
    %% Error Checking
    
    if any(cellfun(@(x) isempty(strfind(equation,x)), matchVars))
        errVars = matchVars(cellfun(@(x) isempty(strfind(equation,x)), matchVars));
        errVars = regexprep(errVars, {'p.', 'f.'}, '');
        error('Could not find parameters: %s', strjoin(errVars, ', '));
    end
    
    %% Rewrite Equation
    
    equation = regexprep(equation, '\s*', ''); % delete spaces
    equation = regexprep(equation, matchVars, modelVars); % rewrite equation
    
    %% Edit Model Name
    
    [filePath,modelName] = fileparts(modelName);
    
    %% Create Model .m File
    
    txt{1} = sprintf('function [out] = %s(params, funcOf)\\n', modelName);
    txt{end+1} = sprintf('%%%% [out] = %s(params, funcOf)\n', modelName);
    txt{end+1} = '%% \n%% Inputs:\n';
    txt{end+1} = '%%   <No Arg>\t\tNo arguments, will return a structure containing the\n%%\t\t\t\t\trequired field names for ''params'' and ''funcOf''\n';
    txt{end+1} = '%%   params\t\t\tA structure that specifes the parameters of the model:\n';
    txt = [txt cellfun(@(x) sprintf('%%%%       %s\n',x), params, 'UniformOutput', false)];
    txt{end+1} = '%%   funcOf\t\t\tA structure that speficies the model function of\n%%\t\t\t\t\tparameters:\n';
    txt = [txt cellfun(@(x) sprintf('%%%%       %s\n',x), funcOf, 'UniformOutput', false)];
    txt{end+1} = '%% \n%% Output:\n';
    txt{end+1} = '%%    out\t\t\tOutput of the model function from the given parameters\n%%\t\t\t\t\treported as a column\n\n';
    txt{end+1} = sprintf('%%%% Written by [NAME] - %s\n', datestr(now, 'mmmm dd, yyyy'));
    txt{end+1} = '\n%%%% Equation\n\n';
    txt{end+1} = sprintf('if nargin < 1\n\tout.params = {''%s''};\n\tout.funcOf = {''%s''};', strjoin(params,''', '''), strjoin(funcOf,''', '''));
    txt{end+1} = sprintf('\nelse\n\tout = %s;\n\tout = out(:);\nend', equation);
    
    fid = fopen(fullfile(filePath, [modelName '.m']), 'w+');
    for i = 1:length(txt)
        fprintf(fid, txt{i});
    end
    fclose(fid);
    
    %% Output
    
    fprintf('Saved As: %s\n', [modelName '.m']);
end