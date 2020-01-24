function [sol, n_sol, has_converged, info] = get_solution(solver_param, optim)
%GET_SOLUTION Solve the multi-objective optimization problem with different solvers.
%   [sol, n_sol, n_sim, has_converged, info] = GET_SOLUTION(solver_param, optim)
%   solver_param.solver_param - struct with the solver data (struct)
%      solver_name - name of the solver (string)
%         'bruteforce' - test all the initial points, nothing more
%         'ga' - MATLAB genetic algoritm 'ga'
%         'gamultiobj' - MATLAB genetic algoritm 'gamultiobj'
%      solver_param.n_split - maximum number of solution evaluated in one vectorized call (integer)
%      solver_param.options - options for the solver (GaOptions or GamultiobjOptions or struct)
%      fct_obj - compute the objective value from the input (function handle)
%         fval = fct_obj(input, n_size);
%         input - parsed and scaled input points (struct of arrays)
%         n_size - number of points (integer)
%         fval - objective function (matrix or array)
%      fct_con_c - compute the inequalities contraints from the input (function handle)
%         c = fct_obj(input, n_size);
%         input - parsed and scaled input points (struct of arrays)
%         n_size - number of points (integer)
%         c - inequalities contraints, c<0 (matrix or empty)
%      fct_con_ceq - compute the equalities contraints from the input (function handle)
%         ceq = fct_obj(input, n_size);
%         input - parsed and scaled input points (struct of arrays)
%         n_size - number of points (integer)
%         ceq - equalities contraints, ceq==0 (matrix or empty)
%      fct_output - compute the output struct from the input (function handle)
%         output = fct_obj(input, n_size);
%         input - parsed and scaled input points (struct of arrays)
%         n_size - number of points (integer)
%         output - struct with the generated output (struct of arrays)
%   optim - struct with the parsed variables (struct)
%      optim.lb - array containing the lower bounds of the variables (array)
%      optim.ub - array containing the upper bounds of the variables (array)
%      optim.int_con - array containing the index of the integer variables (array of indices)
%      optim.input - struct containing the constant (non-optimized) variables (struct of scalars)
%      optim.x0 - matrix containing the scaled initial points (matrix)
%      optim.fct_input - function creating the input struct from the scaled variables (function handle)
%         [input, n_size] = fct_input(x)
%         x - input points to be evaluated (matrix)
%         input - parsed and scaled input points (struct of arrays)
%         n_size - number of points (integer)
%   sol - solution data (struct)
%      sol.fval - values of the objective function (array of matrix)
%      sol.input - struct with the valid points (struct of arrays)
%      sol.output - struct with the generated output (struct of arrays)
%   n_sol - number points contained in the solution (integer)
%   has_converged - return status of the algorithm (boolean)
%   info - information from the solver about the convergence (struct)
%      info.output - struct with information about the solver (struct)
%      info.exitflag - return status of the solver (integer)
%
%   This function performs optimization with different solvers.
%   Please note that the 'gamultiobj' cannot deal with integer variables.
%
%   See also GET_MULTI_OBJ_OPT, GET_PRE_PROC, GET_VECTORIZED, BRUTEFORCE, GA GAMULTIOBJ.

%   Thomas Guillod.
%   2020 - BSD License.

% extract
solver_name = solver_param.solver_name;
fct_output = solver_param.fct_output;
fct_obj = solver_param.fct_obj;
fct_con_c = solver_param.fct_con_c;
fct_con_ceq = solver_param.fct_con_ceq;
n_split = solver_param.n_split;
options = solver_param.options;
fct_input = optim.fct_input;
x0 = optim.x0;
lb = optim.lb;
ub = optim.ub;
int_con = optim.int_con;

% get the functions with vectorized / parallel evaluation
% transpose the values such that n_row is the number of points
fct_obj_tmp = @(x) get_vectorized(x, fct_input, fct_obj, n_split).';
fct_con_c_tmp = @(x) get_vectorized(x, fct_input, fct_con_c, n_split).';
fct_con_ceq_tmp = @(x) get_vectorized(x, fct_input, fct_con_ceq, n_split).';
fct_output_tmp = @(x) get_vectorized(x, fct_input, fct_output, n_split);

% get the constraint function
fct_con_tmp = @(x) deal(fct_con_c_tmp(x), fct_con_ceq_tmp(x));

% select the solver and go
disp('    run optimization')
switch solver_name
    case 'bruteforce'
        [x, fval, exitflag, output] = bruteforce(fct_obj_tmp, x0, lb, ub, fct_con_tmp, options);
        has_converged = (exitflag==1)&&isnumeric(x)&&isnumeric(fval);
    case 'ga'
        n_var = size(x0, 2);
        options = optimoptions(options, 'InitialPopulation', x0);
        options = optimoptions(options, 'OutputFcn', @output_fct_ga);
        options = optimoptions(options, 'Vectorized', 'on');
        options = optimoptions(options, 'Display', 'off');
        [x, fval, exitflag, output] = ga(fct_obj_tmp, n_var, [], [], [], [], lb, ub, fct_con_tmp, int_con, options);
        has_converged = any(exitflag==[0 1 3 4 5])&&isnumeric(x)&&isnumeric(fval);
    case 'gamultiobj'
        n_var = size(x0, 2);
        options = optimoptions(options, 'InitialPopulation', x0);
        options = optimoptions(options, 'OutputFcn', @output_fct_ga);
        options = optimoptions(options, 'Vectorized', 'on');
        options = optimoptions(options, 'Display', 'off');
        assert(isempty(int_con), 'invalid constraints')
        [x, fval, exitflag, output] = gamultiobj(fct_obj_tmp, n_var, [], [], [], [], lb, ub, fct_con_tmp, options);
        has_converged = any(exitflag==[0 1])&&isnumeric(x)&&isnumeric(fval);
    otherwise
        error('invalid solver_name')
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
sol.output = fct_output_tmp(x);

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