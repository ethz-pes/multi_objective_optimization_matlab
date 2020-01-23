function [sol, n_sol, has_converged, info] = get_solution(solver_name, solver_param, optim)
%GET_SOLUTION Solve the multi-objective optimization problem with different solvers.
%   [sol, n_sol, n_sim, has_converged, info] = GET_SOLUTION(solver_name, solver_param, optim)
%   solver_name - name of the solver (string)
%       'bruteforce' - test all the initial points, nothing more
%       'ga' - MATLAB genetic algoritm 'ga'
%       'gamultiobj' - MATLAB genetic algoritm 'gamultiobj'
%   solver_param - struct with the solver data (struct)
%       solver_param.fct_struct - function computing the solution from the inputs (function handle)
%       solver_param.n_split - maximum number of solution evaluated in one vectorized call (integer)
%       solver_param - description for the brute force solver (solver_name is 'bruteforce')
%           solver_param.fct_best - function selecting the best solutions (function handle)
%       solver_param - description for the genetic single obj. solver (solver_name is 'ga')
%           solver_param.fct_obj - function getting single objectives from the solutions (function handle)
%           solver_param.options - function selecting the best solutions (GaOptions object)
%       solver_param - description for the genetic multi obj. solver (solver_name is 'gamultiobj')
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
%   Please note that the 'gamultiobj' cannot deal with integer variables.
%
%   See also GET_OPTIM, GET_PRE_PROC, GET_SOLVE_SOL, GET_SOLVE_OBJ, GA GAMULTIOBJ.

%   Thomas Guillod.
%   2020 - BSD License.

% extract
fct_struct = solver_param.fct_struct;
fct_obj = solver_param.fct_obj;
fct_con_c = solver_param.fct_con_c;
fct_con_ceq = solver_param.fct_con_ceq;
n_split = solver_param.n_split;
options = solver_param.options;
fct_input = optim.fct_input;
x0_mat = optim.x0_mat;
lb = optim.lb;
ub = optim.ub;
int_con = optim.int_con;

% run the genetic algorithm
disp('    init optimization')

fct_obj_tmp = @(x) get_solve_sol(x, fct_input, fct_obj, n_split);
fct_con_c_tmp = @(x) get_solve_sol(x, fct_input, fct_con_c, n_split);
fct_con_ceq_tmp = @(x) get_solve_sol(x, fct_input, fct_con_ceq, n_split);
fct_struct_tmp = @(x) get_solve_sol(x, fct_input, fct_struct, n_split);

fct_obj_tmp = @(x) get_obj(x, fct_obj_tmp);
fct_con_tmp = @(x) get_con(x, fct_con_c_tmp, fct_con_ceq_tmp);

switch solver_name
    case 'bruteforce'
        [x, fval, exitflag, output] = bruteforce(fct_obj_tmp, x0_mat, lb, ub, fct_con_tmp, options);
        has_converged = (exitflag==1)&&isnumeric(x)&&isnumeric(fval);
    case 'ga'
        n_var = size(x0_mat, 2);
        options = optimoptions(options, 'InitialPopulation', x0_mat);
        options = optimoptions(options, 'OutputFcn', @output_fct_ga);
        options = optimoptions(options, 'Vectorized', 'on');
        options = optimoptions(options, 'Display', 'off');
        [x, fval, exitflag, output] = ga(fct_obj_tmp, n_var, [], [], [], [], lb, ub, fct_con_tmp, int_con, options);
        has_converged = any(exitflag==[0 1 3 4 5])&&isnumeric(x)&&isnumeric(fval);
    case 'gamultiobj'
        n_var = size(x0_mat, 2);
        options = optimoptions(options, 'InitialPopulation', x0_mat);
        options = optimoptions(options, 'OutputFcn', @output_fct_ga);
        options = optimoptions(options, 'Vectorized', 'on');
        options = optimoptions(options, 'Display', 'off');
        assert(isempty(int_con), 'invalid data')
        [x, fval, exitflag, output] = gamultiobj(fct_obj_tmp, n_var, [], [], [], [], lb, ub, fct_con_tmp, options);
        has_converged = any(exitflag==[0 1])&&isnumeric(x)&&isnumeric(fval);
    otherwise
        error('invalid data')
end

% get the convergence info
disp('    eval convergence')
n_sol = size(x, 1);
info.output = output;
info.exitflag = exitflag;

% get the solution for the optimal point
disp('    eval solution')
sol.fval = fval;
sol.input = fct_input(x);
sol.struct = fct_struct_tmp(x);

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

function val = get_obj(x, fct)

val = fct(x);
val = val.';

end

function [c, ceq] = get_con(x, fct_con_c, fct_con_ceq)

c = fct_con_c(x);
ceq = fct_con_ceq(x);
c = c.';
ceq = ceq.';

end

