function val = get_solve_obj(x, input, var_optim, fct_solve, fct_valid, fct_obj, n_split)

% sweep
[sweep, n_sweep] = get_sweep_from_x(x, var_optim);

% sol
[sol, idx] = get_solve_raw(input, sweep, fct_solve, fct_valid, n_split, n_sweep);

% objective
val_valid = fct_obj(sol, nnz(idx));

% assign
val = NaN(size(val_valid, 1), n_sweep);
val(:,idx) = val_valid;
val = val.';

end
