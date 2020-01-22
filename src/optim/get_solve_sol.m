function sol = get_solve_sol(x, input, var_scale, fct_solve, n_split)
%GET_SOLVE_SOL Compute and return the solution of the problem.
%   val = GET_SOLVE_SOL(x, input, var_scale, fct_solve, fct_obj, n_split)
%   x - matrix containing the scaled points to be computed (matrix of float)
%   input - struct containing the constant (non-optimized) variables (struct of scalars)
%   var_scale - cell containing the function to unscale the variables (cell of struct)
%   fct_solve - function computing the solution from the inputs (function handle)
%   n_split - maximum number of solution evaluated in one vectorized call (integer)
%   sol - computed solution of the valid combinations (struct of arrays)
%   n_sol - number points contained in the solution (integer)
%
%   The following steps are computed:
%      - Unscale the variables to get the points to be computed
%      - Compute the points (parallel / vectorized), keeping only the valid desings
%
%   See also GET_SOLVE_RAW, GET_SOLVE_OBJ, GET_SOLUTION.

% parse and unscale the variable
disp('        get var')
[sweep, n_sweep] = get_sweep_from_x(x, var_scale);

% compute the solution
sol = get_solve_raw(input, sweep, fct_solve, n_split, n_sweep);

end