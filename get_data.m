function [var_param, solver_param] = get_data(solver_name)
%GET_DATA Get the data for a (example) multi-objective optimization problem.
%   [var_param, solver_param] = get_data(solver_name)
%   var_param - struct with the variable description (struct)
%   solver_param - struct with the solver data (struct)
%
%   Solve an optimization problem with:
%      - Multiple variables
%      - Integer variables
%      - Upper and lower bounds
%      - Inequality constraints
%      - Equality constraints
%      - Non continuous objective function
%      - Single-objective or multi-objective goals
%
%   Use the followig strategies:
%      - brute force grid search (mixed integer)
%      - single-objective genetic algorithm (mixed integer)
%      - multi-objective genetic algorithm (continuous variables)
%
%   The problem solved in this example is trivial and not very interesting.
%
%   See also RUN_OPTIM, GET_MULTI_OBJ_OPT, GET_PRE_PROC, GET_SOLUTION.
%
%   (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

switch solver_name
    case 'bruteforce'
        var_param = get_var_param('mixed_integer');
        
        options = struct('ConstraintToleranceEq', 1e-3, 'ConstraintToleranceInEq', 1e-3);
        solver_param = get_solver_param('single_objective', solver_name, options);
    case 'ga'
        var_param = get_var_param('mixed_integer');
        
        options = optimoptions (@ga);
        options = optimoptions(options, 'TolFun', 1e-6);
        options = optimoptions(options, 'ConstraintTolerance', 1e-3);
        options = optimoptions(options, 'Generations', 20);
        options = optimoptions(options, 'PopulationSize', 2000);
        solver_param = get_solver_param('single_objective', solver_name, options);
    case 'gamultiobj'
        var_param = get_var_param('continuous');
        
        options = optimoptions(@gamultiobj);
        options = optimoptions(options, 'TolFun', 1e-6);
        options = optimoptions(options, 'ConstraintTolerance', 1e-3);
        options = optimoptions(options, 'Generations', 20);
        options = optimoptions(options, 'PopulationSize', 700);
        solver_param = get_solver_param('multi_objective', solver_name, options);
    otherwise
        error('invalid solver_name')
end

end

function var_param = get_var_param(type)
%GET_VAR_PARAM Get the data for a (example) multi-objective optimization problem.
%   var_param = GET_VAR_PARAM(type)
%   type - type of the variables (string)
%       'mixed_integer' - problem with integer variable
%       'continuous' - problem without integer variable
%   var_param - struct with the variable description (struct)

% variables list
var = {};
var{end+1} = struct('type', 'float', 'name', 'x_1', 'scale', 'lin', 'vec', linspace(0, 3, 25), 'lb', 0.0, 'ub', 3.0);
var{end+1} = struct('type', 'float', 'name', 'x_2', 'scale', 'log', 'vec', logspace(log10(1), log10(3), 25), 'lb', 1.0, 'ub', 3.0);
switch type
    case 'mixed_integer'
        var{end+1} = struct('type', 'integer', 'name', 'x_3','vec', [5 7 9], 'set', [5 7 9]);
    case 'continuous'
        var{end+1} = struct('type', 'scalar', 'name', 'x_3', 'v', 5);
    otherwise
        error('invalid type')
end
var{end+1} = struct('type', 'scalar', 'name', 'x_4', 'v', 2);

% assign
var_param.var = var; % cell of struct with the different variable description
var_param.n_max = 100e3; % maximum number of initial points for avoid out of memory crashes
var_param.fct_select = @(input, n_size) true(1, n_size); % check if the generated iniitial points should be included

end

function solver_param = get_solver_param(type, solver_name, options)
%GET_SOLVER_PARAM Get the data for a (example) multi-objective optimization problem.
%   solver_param = GET_SOLVER_PARAM(type, solver_name, options)
%   type - type of the problem (string)
%       'single_objective' - scalar valued ojective function
%       'multi_objective' - vector valued ojective function
%   solver_name - name of the solver (string)
%   options - options for the solver (GaOptions or GamultiobjOptions or struct)
%   solver_param - struct with the solver data (struct)

solver_param.solver_name = solver_name; % name of the solver
solver_param.options = options; % options for the solver
solver_param.n_split = 500; % maximum number of solution evaluated in one vectorized call
solver_param.fct_output = @get_output; % compute the output struct from the input
solver_param.fct_con_c = @get_con_c; % compute the inequalities contraints from the input
solver_param.fct_con_ceq = @get_con_ceq; % compute the equalities contraints from the input
switch type
    case 'single_objective'
        solver_param.fct_obj = @get_obj_single; % compute the objective value from the input
    case 'multi_objective'
        solver_param.fct_obj = @get_obj_multi; % compute the objective value from the input
    otherwise
        error('invalid type')
end

end

function c = get_con_c(input, n_size)
%GET_CON_C Compute the inequalities contraints from the input.
%   c = GET_CON_C(input, n_size)
%   input - parsed and scaled input points (struct of arrays)
%   n_size - number of points (integer)
%   c - inequalities contraints, c<0 (matrix or empty)

[y_1, y_2] = get_raw(input);
c = [y_1-10 ; y_2-10];

end

function ceq = get_con_ceq(input, n_size)
%GET_CON_CEQ Compute the equalities contraints from the input.
%   ceq = GET_CON_CEQ(input, n_size)
%   input - parsed and scaled input points (struct of arrays)
%   n_size - number of points (integer)
%   ceq - equalities contraints, ceq==0 (matrix or empty)

ceq = [];

end


function fval = get_obj_single(input, n_size)
%GET_OBJ_SINGLE Compute the single-objective value from the input.
%   fval = GET_OBJ_SINGLE(input, n_size)
%   input - parsed and scaled input points (struct of arrays)
%   n_size - number of points (integer)
%   fval - objective function (array)

[y_1, y_2] = get_raw(input);
fval = y_1+y_2;

end

function fval = get_obj_multi(input, n_size)
%GET_OBJ_MULTI Compute the multi-objective values from the input.
%   fval = GET_OBJ_MULTI(input, n_size)
%   input - parsed and scaled input points (struct of arrays)
%   n_size - number of points (integer)
%   fval - objective function (matrix)

[y_1, y_2] = get_raw(input);
fval = [y_1 ; y_2];

end

function sol = get_output(input, n_size)
%GET_OBJ_OUTPUT Compute the output struct from the input.
%   sol = GET_OBJ_OUTPUT(input, n_size)
%   input - parsed and scaled input points (struct of arrays)
%   n_size - number of points (integer)
%   output - struct with the generated output (struct of arrays)

[y_1, y_2] = get_raw(input);
sol.y_1 = y_1;
sol.y_2 = y_2;

end

function [y_1, y_2] = get_raw(input)
%GET_RAW Mathematical description of the function to be optimized.
%   [y_1, y_2] = GET_RAW(input)
%   input - parsed and scaled input points (struct of arrays)
%   y_1 - first output values (array)
%   y_2 - second output values (array)

% assign
x_1 = input.x_1;
x_2 = input.x_2;
x_3 = input.x_3;
x_4 = input.x_4;

% compute
y_1 = x_1.^2+(x_2-2).^2+x_3;
y_2 = 0.5*((x_1-2).^2+(x_2+1).^2)+2+x_4;

end
