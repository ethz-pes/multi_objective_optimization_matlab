function param = get_data(solver_name)

%% options
n_split = 1000;

switch solver_name
    case 'bruteforce'
        var_param = get_var_param(true);
        
        options = struct('ConstraintToleranceEq', 1e-3, 'ConstraintToleranceInEq', 1e-3);
        
        solver_param = struct(...
            'n_split', n_split,...
            'fct_solve', @get_solve,...
            'fct_obj', @get_obj_scalar,...
            'fct_con', @get_con,...
            'options', options...
            );
    case 'ga'
        var_param = get_var_param(true);
        
        options = optimoptions (@ga);
        options = optimoptions(options, 'TolFun', 1e-6);
        options = optimoptions(options, 'ConstraintTolerance', 1e-3);
        options = optimoptions(options, 'Generations', 20);
        options = optimoptions(options, 'PopulationSize', 2000);
        
        solver_param = struct(...
            'n_split', n_split,...
            'fct_solve', @get_solve,...
            'fct_obj', @get_obj_scalar,...
            'fct_con', @get_con,...
            'options', options...
            );
    case 'gamultiobj'
        var_param = get_var_param(false);
        
        options = optimoptions(@gamultiobj);
        options = optimoptions(options, 'TolFun', 1e-6);
        options = optimoptions(options, 'ConstraintTolerance', 1e-3);
        options = optimoptions(options, 'Generations', 20);
        options = optimoptions(options, 'PopulationSize', 700);
        
        solver_param = struct(...
            'n_split', n_split,...
            'fct_solve', @get_solve,...
            'fct_obj', @get_obj_vector,...
            'fct_con', @get_con,...
            'options', options...
            );
    otherwise
        error('invalid data')
end

% assign
param.solver_param = solver_param;
param.var_param = var_param;
param.solver_name = solver_name;

end

function [cnq, ceq] = get_con(sol, n_sweep)

cnq = [sol.y_1-10 ; sol.y_2-10];
ceq = [];

end

function val = get_obj_scalar(sol, n_sol)

keyboard

val = sol.y_1+sol.y_2;

end

function val = get_obj_vector(sol, n_sol)

val = [sol.y_1 ; sol.y_2];

end

function var_param = get_var_param(integer)

var = {};
var{end+1} = struct('type', 'float', 'name', 'x_1', 'scale', 'lin', 'v', 1.5, 'vec', linspace(0, 3, 25), 'lb', 0.0, 'ub', 3.0);
var{end+1} = struct('type', 'float', 'name', 'x_2', 'scale', 'log', 'v', 2.0, 'vec', logspace(log10(1), log10(3), 25), 'lb', 1.0, 'ub', 3.0);
if integer==true
    var{end+1} = struct('type', 'integer', 'name', 'x_3', 'v', 7 ,'vec', [5 7 9], 'set', [5 7 9]);
    var{end+1} = struct('type', 'scalar', 'name', 'x_4', 'v', 2);
else
    var{end+1} = struct('type', 'scalar', 'name', 'x_3', 'v', 5);
    var{end+1} = struct('type', 'scalar', 'name', 'x_4', 'v', 2);
end

var_param = struct('var', {var}, 'n_max', 100e3, 'fct_select', @(input, n_sol) true(1, n_sol));

end

function sol = get_solve(input, n_sol)

assert(n_sol>=1, 'invalid data')

% assign
x_1 = input.x_1;
x_2 = input.x_2;
x_3 = input.x_3;
x_4 = input.x_4;

% compute
y_1 = x_1.^2+x_2.^2+x_3;
y_2 = 0.5*((x_1-2).^2+(x_2+1).^2)+2+x_4;

% assign
sol.y_1 = y_1;
sol.y_2 = y_2;
sol.x_1 = x_1;
sol.x_2 = x_2;
sol.x_3 = x_3;
sol.x_4 = x_4;

end
