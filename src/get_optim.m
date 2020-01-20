function data = get_optim(name, param)

%% init
disp(['============================= ' name])

% init
[optim, n_var, n_sweep] = get_pre_proc(param.var_param);

disp('pre_proc')
disp(['    n_var = ' num2str(n_var)])
disp(['    n_sweep = ' num2str(n_sweep)])

% solve
disp('solution')
[sol_valid, n_sol_valid, has_converged, n_sol_sim, info] = get_solution(param.solver, param.solver_param, optim);

% sol
disp('solution')
disp(['    n_var = ' num2str(n_var)])
disp(['    n_sweep = ' num2str(n_sweep)])
disp(['    n_sol_sim = ' num2str(n_sol_sim)])
disp(['    n_sol_valid = ' num2str(n_sol_valid)])
disp(['    has_converged = ' num2str(has_converged)])

% assign
data.n_var = n_var;
data.n_sweep = n_sweep;
data.n_sol_sim = n_sol_sim;
data.n_sol_valid = n_sol_valid;
data.has_converged = has_converged;
data.sol_valid = sol_valid;
data.info = info;

end