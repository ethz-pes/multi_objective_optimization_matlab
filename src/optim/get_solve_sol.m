function [sol, n_sol] = get_solve_sol(x, input, var_scale, fct_solve, fct_valid, n_split)

% sweep
[sweep, n_sweep] = get_sweep_from_x(x, var_scale);

% sol
[sol, idx] = get_solve_raw(input, sweep, fct_solve, fct_valid, n_split, n_sweep);
n_sol = nnz(idx);

end