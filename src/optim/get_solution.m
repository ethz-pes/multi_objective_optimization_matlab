function [sol, n_sol, has_converged, n_sol_sim, info] = get_solution(solver, solver_param, optim)

switch solver
    case 'brute'
        [sol, n_sol, has_converged, n_sol_sim, info] = get_optim_brute(solver_param, optim);
    case 'ga'
        [sol, n_sol, has_converged, n_sol_sim, info] = get_optim_ga(solver_param, optim);
    case 'gamultiobj'
        [sol, n_sol, has_converged, n_sol_sim, info] = get_optim_gamultiobj(solver_param, optim);
    otherwise
        error('invalid data')
end

end

function [sol, n_sol, has_converged, n_sol_sim, info] = get_optim_brute(solver_param, optim)

% extract
fct_solve = solver_param.fct_solve;
fct_valid = solver_param.fct_valid;
fct_obj = solver_param.fct_obj;
n_split = solver_param.n_split;
input = optim.input;
var_optim = optim.var_optim;
x0 = optim.x0;

% run
[sol, n_sol] = solve_final(x0, input, var_optim, fct_solve, fct_valid, n_split);

% get bests
idx_valid = fct_obj(sol, n_sol);
sol = get_struct_idx(sol, idx_valid);
n_sol = nnz(idx_valid);
n_sol_sim = size(x0, 1);

% info
has_converged = true;
info = struct();

end

function [sol, n_sol, has_converged, n_sol_sim, info] = get_optim_ga(solver_param, optim)

% extract
fct_solve = solver_param.fct_solve;
fct_valid = solver_param.fct_valid;
fct_obj = solver_param.fct_obj;
n_split = solver_param.n_split;
options = solver_param.options;
input = optim.input;
var_optim = optim.var_optim;
x0 = optim.x0;
lb = optim.lb;
ub = optim.ub;
int_con = optim.int_con;

% merge
fct_optim_tmp = @(x) get_solve_obj(x, input, var_optim, fct_solve, fct_valid, fct_obj, n_split);
n_var = size(x0, 2);

% options
options = optimoptions(options, 'InitialPopulation', x0);
options = optimoptions(options, 'OutputFcn', @output_fct);

% run
[x, f_val, exitflag, output] = ga(fct_optim_tmp, n_var, [], [], [], [], lb, ub, [], int_con, options);

% info
has_converged = (exitflag==1)&&all(isfinite(x))&&isfinite(f_val);
n_sol_sim = output.funccount;
info.n_gen = output.generations;
info.message = output.message;

% extract
[sol, n_sol] = solve_final(x, input, var_optim, fct_solve, fct_valid, n_split);

end

function [sol, n_sol, has_converged, n_sol_sim, info] = get_optim_gamultiobj(solver_param, optim)

% extract
fct_solve = solver_param.fct_solve;
fct_valid = solver_param.fct_valid;
fct_obj = solver_param.fct_obj;
n_split = solver_param.n_split;
options = solver_param.options;
input = optim.input;
var_optim = optim.var_optim;
x0 = optim.x0;
lb = optim.lb;
ub = optim.ub;
int_con = optim.int_con;

% check
assert(isempty(int_con), 'invalid data')

% merge
fct_optim_tmp = @(x) get_solve_obj(x, input, var_optim, fct_solve, fct_valid, fct_obj, n_split);
n_var = size(x0, 2);

% x0
options = optimoptions(options, 'InitialPopulation', x0);
options = optimoptions(options, 'OutputFcn', @output_fct);

% run
[x, f_val, exitflag, output] = gamultiobj(fct_optim_tmp, n_var, [], [], [], [], lb, ub, [], options);

% info
has_converged = (exitflag==1)&&all(isfinite(x))&&isfinite(f_val);
n_sol_sim = output.funccount;
info.n_gen = output.generations;
info.message = output.message;

% extract
[sol, n_sol] = solve_final(x, input, var_optim, fct_solve, fct_valid, n_split);

end

function [state,options,optchanged] = output_fct(options, state, flag)

optchanged = false;
disp(['    ' flag ' / ' num2str(state.Generation) ' / ' num2str(state.FunEval)])

end