function print_progress(i, n)

%%% global variables
[print,unit] = get_global_parameters('print', 'unit.name'); 

%%% print increment (if printing)
if ~print.quiet && ~mod(i, print.inc) % if print increment
  str = sprintf('%%%dd', print.digits);
  fprintf(['  %s', str, ' of %d...\n'], capitalize(unit), i, n);
end