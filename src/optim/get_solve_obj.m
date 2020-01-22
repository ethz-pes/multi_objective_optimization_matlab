function val = get_solve_obj(x, input, var_scale, fct_solve, fct_obj, n_split)
%GET_SOLVE_OBJ Compute the solution and the objective function.
%   val = GET_SOLVE_OBJ(x, input, var_scale, fct_solve, fct_obj, n_split)
%   x - matrix containing the scaled points to be computed (matrix of float)
%   input - struct containing the constant (non-optimized) variables (struct of scalars)
%   var_scale - cell containing the function to unscale the variables (cell of struct)
%   fct_solve - function computing the solution from the inputs (function handle)
%   fct_obj - function getting the objectives from the solutions (function handle)
%   n_split - maximum number of solution evaluated in one vectorized call (integer)
%   val - computed values by the objective function (matrix of float or array of float)
%
%   The following steps are computed:
%      - Unscale the variables to get the points to be computed
%      - Compute the points (parallel / vectorized), keeping only the valid desings
%      - Computing the objective function on the solutions
%
%   See also GET_SOLVE_RAW, GET_SOLVE_SOL, GET_SOLUTION.

% parse and unscale the variable
disp('        get var')
[sweep, n_sweep] = get_sweep_from_x(x, var_scale);

% compute the solution
sol = get_solve_raw(input, sweep, fct_solve, n_split, n_sweep);

% get the value of the objective
disp('        get objective')
val = fct_obj(sol, n_sweep).';

end
