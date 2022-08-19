function print_progress(i, n)

%%% global variables
print = get_global_parameters('print');

%%% print increment (if printing)
if ~print.quiet && ~mod(i, print.inc) % if print increment
  fprintf(print.str, i, n); % print message
end