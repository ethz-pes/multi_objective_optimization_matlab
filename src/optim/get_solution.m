function [sol, n_sol, n_sim, has_converged, info] = get_solution(solver_name, solver_param, optim)
%GET_SOLUTION Solve the multi-objective optimization problem with different solvers.
%   [sol, n_sol, n_sim, has_converged, info] = GET_SOLUTION(solver_name, solver_param, optim)
%   solver_name - name of the solver (string)
%       'brute_force' - test all the initial points, nothing more
%       'genetic_single_obj' - MATLAB genetic algoritm 'ga'
%       'genetic_multi_obj' - MATLAB genetic algoritm 'gamultiobj'
%   solver_param - struct with the solver data (struct)
%       solver_param.fct_solve - function computing the solution from the inputs (function handle)
%       solver_param.fct_valid - function determining if a solution is valid to save memory (function handle)
%       solver_param.n_split - maximum number of solution evaluated in one vectorized call (integer)
%       solver_param - description for the brute force solver (solver_name is 'brute_force')
%           solver_param.fct_best - function selecting the best solutions (function handle)
%       solver_param - description for the genetic single obj. solver (solver_name is 'genetic_single_obj')
%           solver_param.fct_obj - function getting single objectives from the solutions (function handle)
%           solver_param.options - function selecting the best solutions (GaOptions object)
%       solver_param - description for the genetic multi obj. solver (solver_name is 'genetic_multi_obj')
%           solver_param.fct_obj - function getting a multiple objectives from the solutions (function handle)
%           solver_param.options - function selecting the best solutions (GamultiobjOptions object)
%   optim - struct with the parsed variables (struct)
%      optim.lb - array containing the lower bounds of the variables (array of float)
%      optim.ub - array containing the upper bounds of the variables (array of float)
%      optim.int_con - array containing the index of the integer variables (array of integer)
%      optim.input - struct containing the constant (non-optimized) variables (struct of scalars)
%      optim.x0 - matrix containing the scaled initial points (matrix of float)
%      optim.var_scale - cell containing the function to unscale the variables (cell of struct)
%         optim.var_scale{i}.name - name of the variable (string)
%         optim.var_scale{i}.fct_unscale - function for unscaling the variables (function handle)
%   sol - solution data (struct of arrays)
%   n_sol - computed number points contained in the solution (integer)
%   n_sim - number of computed points during the optimization procedure (integer)
%   has_converged - return status of the algorithm (boolean)
%   info - information from the solver about the convergence (struct)
%
%   This function performs optimization with different solvers.
%   Please note that the 'genetic_multi_obj' cannot deal with integer variables.
%
%   See also GET_OPTIM, GET_PRE_PROC, GET_SOLVE_SOL, GET_SOLVE_OBJ, GA GAMULTIOBJ.

%   Thomas Guillod.
%   2020 - BSD License.

switch solver_name
    case 'brute_force'
        [sol, n_sol, n_sim, has_converged, info] = get_brute_force(solver_param, optim);
    case 'genetic_single_obj'
        [sol, n_sol, n_sim, has_converged, info] = get_genetic_single_obj(solver_param, optim);
    case 'genetic_multi_obj'
        [sol, n_sol, n_sim, has_converged, info] = get_genetic_multi_obj(solver_param, optim);
    case 'pattern_search'
        [sol, n_sol, n_sim, has_converged, info] = get_pattern_search(solver_param, optim);
    otherwise
        error('invalid data')
end

end

function [sol, n_sol, n_sim, has_converged, info] = get_brute_force(solver_param, optim)
%GET_BRUTE_FORCE Solve a multi-objective optimization with brute force.
%   [sol, n_sol, n_sim, has_converged, info] = GET_BRUTE_FORCE(solver_param, optim)
%   solver_param - struct with the solver data (struct)
%   optim - struct with the parsed variables (struct)
%   sol - solution data (struct of arrays)
%   n_sol - number points contained in the solution (integer)
%   n_sim - number of computed points during the optimization procedure (integer)
%   has_converged - return status of the algorithm (boolean)
%   info - information from the solver about the convergence (struct)

% extract
fct_solve = solver_param.fct_solve;
fct_valid = solver_param.fct_valid;
fct_best = solver_param.fct_best;
n_split = solver_param.n_split;
input = optim.input;
var_scale = optim.var_scale;
x0_mat = optim.x0_mat;

% compute all the solution of the initial points
disp('    init optimization')
[sol, n_sol] = get_solve_sol(x0_mat, input, var_scale, fct_solve, fct_valid, n_split);

% get the convergence info
disp('    eval convergence')
n_sim = size(x0_mat, 1);
has_converged = true;
info = struct();

% keep the best solutions
disp('    eval solution')
idx_valid = fct_best(sol, n_sol);
sol = get_struct_idx(sol, idx_valid);
n_sol = nnz(idx_valid);

end

function [sol, n_sol, n_sim, has_converged, info] = get_genetic_single_obj(solver_param, optim)
%GET_GENETIC_SINGLE_OBJ Solve a single-objective optimization with the MATLAB genetic algorithm.
%   [sol, n_sol, n_sim, has_converged, info] = GET_GENETIC_SINGLE_OBJ(solver_param, optim)
%   solver_param - struct with the solver data (struct)
%   optim - struct with the parsed variables (struct)
%   sol - solution data (struct of arrays)
%   n_sol - number points contained in the solution (integer)
%   n_sim - number of computed points during the optimization procedure (integer)
%   has_converged - return status of the algorithm (boolean)
%   info - information from the solver about the convergence (struct)

% extract
fct_solve = solver_param.fct_solve;
fct_valid = solver_param.fct_valid;
fct_obj = solver_param.fct_obj;
n_split = solver_param.n_split;
options = solver_param.options;
input = optim.input;
var_scale = optim.var_scale;
x0_mat = optim.x0_mat;
lb = optim.lb;
ub = optim.ub;
int_con = optim.int_con;

% set algorithm default options
disp('    set options')
options = optimoptions(options, 'InitialPopulation', x0_mat);
options = optimoptions(options, 'OutputFcn', @output_fct_ga);
options = optimoptions(options, 'Vectorized', 'on');
options = optimoptions(options, 'Display', 'off');

% run the genetic algorithm
disp('    init optimization')
n_var = size(x0_mat, 2);
fct_optim_tmp = @(x) get_solve_obj(x, input, var_scale, fct_solve, fct_valid, fct_obj, n_split);
[x, f_val, exitflag, output] = ga(fct_optim_tmp, n_var, [], [], [], [], lb, ub, [], int_con, options);

% get the convergence info
disp('    eval convergence')
has_converged = (exitflag==1)&&all(isfinite(x))&&isfinite(f_val);
n_sim = output.funccount;
info.n_gen = output.generations;
info.message = output.message;

% get the solution for the optimal point
disp('    eval solution')
[sol, n_sol] = get_solve_sol(x, input, var_scale, fct_solve, fct_valid, n_split);

end

function [sol, n_sol, n_sim, has_converged, info] = get_genetic_multi_obj(solver_param, optim)
%GET_GENETIC_MULTI_OBJ Solve a multi-objective optimization with the MATLAB genetic algorithm.
%   [sol, n_sol, n_sim, has_converged, info] = GET_GENETIC_MULTI_OBJ(solver_param, optim)
%   solver_param - struct with the solver data (struct)
%   optim - struct with the parsed variables (struct)
%   sol - solution data (struct of arrays)
%   n_sol - number points contained in the solution (integer)
%   n_sim - number of computed points during the optimization procedure (integer)
%   has_converged - return status of the algorithm (boolean)
%   info - information from the solver about the convergence (struct)

% extract
fct_solve = solver_param.fct_solve;
fct_valid = solver_param.fct_valid;
fct_obj = solver_param.fct_obj;
n_split = solver_param.n_split;
options = solver_param.options;
input = optim.input;
var_scale = optim.var_scale;
x0_mat = optim.x0_mat;
lb = optim.lb;
ub = optim.ub;
int_con = optim.int_con;
assert(isempty(int_con), 'invalid data')

% set algorithm default options
disp('    set options')
options = optimoptions(options, 'InitialPopulation', x0_mat);
options = optimoptions(options, 'OutputFcn', @output_fct_ga);
options = optimoptions(options, 'Vectorized', 'on');
options = optimoptions(options, 'UseParallel', true);
options = optimoptions(options, 'Display', 'off');

% run the genetic algorithm
disp('    init optimization')
n_var = size(x0_mat, 2);
fct_optim_tmp = @(x) get_solve_obj(x, input, var_scale, fct_solve, fct_valid, fct_obj, n_split);
[x, f_val, exitflag, output] = gamultiobj(fct_optim_tmp, n_var, [], [], [], [], lb, ub, [], options);

% get the convergence info
disp('    eval convergence')
has_converged = (exitflag==1)&&all(isfinite(x))&&isfinite(f_val);
n_sim = output.funccount;
info.n_gen = output.generations;
info.message = output.message;

% get the solution for the optimal point
disp('    eval solution')
[sol, n_sol] = get_solve_sol(x, input, var_scale, fct_solve, fct_valid, n_split);

end

function [sol, n_sol, n_sim, has_converged, info] = get_pattern_search(solver_param, optim)
%GET_GENETIC_SINGLE_OBJ Solve a single-objective optimization with the MATLAB genetic algorithm.
%   [sol, n_sol, n_sim, has_converged, info] = GET_GENETIC_SINGLE_OBJ(solver_param, optim)
%   solver_param - struct with the solver data (struct)
%   optim - struct with the parsed variables (struct)
%   sol - solution data (struct of arrays)
%   n_sol - number points contained in the solution (integer)
%   n_sim - number of computed points during the optimization procedure (integer)
%   has_converged - return status of the algorithm (boolean)
%   info - information from the solver about the convergence (struct)

% extract
fct_solve = solver_param.fct_solve;
fct_valid = solver_param.fct_valid;
fct_obj = solver_param.fct_obj;
n_split = solver_param.n_split;
options = solver_param.options;
input = optim.input;
var_scale = optim.var_scale;
x0_vec = optim.x0_vec;
lb = optim.lb;
ub = optim.ub;
int_con = optim.int_con;

% check
assert(isempty(int_con), 'invalid data')

% set algorithm default options
disp('    set options')
options = optimoptions(options, 'OutputFcn', @output_fct_ps);
options = optimoptions(options, 'Vectorized', 'on');
options = optimoptions(options, 'Display', 'off');

% run the genetic algorithm
disp('    init optimization')
fct_optim_tmp = @(x) get_solve_obj(x, input, var_scale, fct_solve, fct_valid, fct_obj, n_split);
[x, f_val, exitflag, output] = patternsearch(fct_optim_tmp, x0_vec, [], [], [], [], lb, ub, [], options);

% get the convergence info
disp('    eval convergence')
has_converged = (exitflag==1)&&all(isfinite(x))&&isfinite(f_val);
n_sim = output.funccount;
info.iterations = output.iterations;
info.message = output.message;

% get the solution for the optimal point
disp('    eval solution')
[sol, n_sol] = get_solve_sol(x, input, var_scale, fct_solve, fct_valid, n_split);

end

function [stop,options,optchanged] = output_fct_ps(optimvalues,options,flag)
%OUTPUT_FCN Display function for the genetic algorithms.
%   [state, options, optchanged] = OUTPUT_FCN(options, state, flag)
%   options - options of the genetic algorithm (optim object)
%   state - state information about the solver (struct)
%   flag - string with the iteration type (string)
%   optchanged - switch if the options are updated (boolean)

stop = false;
optchanged = false;
disp(['    ' flag ' / ' num2str(optimvalues.iteration) ' / ' num2str(optimvalues.funccount)])

end

function [state, options, optchanged] = output_fct_ga(options, state, flag)
%OUTPUT_FCN Display function for the genetic algorithms.
%   [state, options, optchanged] = OUTPUT_FCN(options, state, flag)
%   options - options of the genetic algorithm (optim object)
%   state - state information about the solver (struct)
%   flag - string with the iteration type (string)
%   optchanged - switch if the options are updated (boolean)

optchanged = false;
disp(['    ' flag ' / ' num2str(state.Generation) ' / ' num2str(state.FunEval)])

end