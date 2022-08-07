function set_global_variables(param, value)

global GLOBAL_PARAMETERS;

evalStr = sprintf('GLOBAL_PARAMETERS.%s = value;', param);
eval(evalStr);
