function param = get_data(solver)

%% options
n_split = 1000;
fct_solve = @(input, n_sol) get_solve(input, n_sol);
fct_valid = @(sol, n_sol) get_valid(sol, n_sol);
fct_obj_scalar = @(sol, n_sol) get_obj_scalar(sol, n_sol);
fct_obj_vector = @(sol, n_sol) get_obj_vector(sol, n_sol);

switch solver
    case 'brute'
        var_param = get_var_param(true);
        solver_param = struct(...
            'n_split', n_split,...
            'fct_solve', fct_solve,...
            'fct_valid', fct_valid,...
            'fct_obj', fct_valid...
            );
    case 'ga'
        var_param = get_var_param(true);
        
        options = optimoptions (@ga);
        options = optimoptions(options, 'Vectorized', 'on');
        options = optimoptions(options, 'Display', 'off');
        options = optimoptions(options, 'TolFun', 1e-6);
        options = optimoptions(options, 'TolCon', 1e-3);
        options = optimoptions(options, 'TimeLimit', 60.0);
        options = optimoptions(options, 'Generations', 20);
        options = optimoptions(options, 'StallGenLimit', 10);
        options = optimoptions(options, 'PopulationSize', 5000);
        
        solver_param = struct(...
            'n_split', n_split,...
            'fct_solve', fct_solve,...
            'fct_valid', fct_valid,...
            'fct_obj', fct_obj_scalar,...
            'options', options...
            );
    case 'gamultiobj'
        var_param = get_var_param(false);
        
        options = optimoptions(@gamultiobj);
        options = optimoptions(options, 'Vectorized', 'on');
        options = optimoptions(options, 'UseParallel', true);
        options = optimoptions(options, 'Display', 'off');
        options = optimoptions(options, 'TolFun', 1e-6);
        options = optimoptions(options, 'TolCon', 1e-3);
        options = optimoptions(options, 'TimeLimit', 60.0);
        options = optimoptions(options, 'Generations', 20);
        options = optimoptions(options, 'StallGenLimit', 10);
        options = optimoptions(options, 'PopulationSize', 5000);
        
        solver_param = struct(...
            'n_split', n_split,...
            'fct_solve', fct_solve,...
            'fct_valid', fct_valid,...
            'fct_obj', fct_obj_vector,...
            'options', options...
            );
    otherwise
        error('invalid data')
end

% assign
param.solver_param = solver_param;
param.var_param = var_param;
param.solver = solver;

end

function is_valid = get_valid(sol, n_sol)

is_valid = true(1, n_sol);
is_valid = is_valid&(sol.y_1<10);
is_valid = is_valid&(sol.y_2<10);

end

function val = get_obj_scalar(sol, n_sol)

% objective
if n_sol==0
    val = NaN(1, 0);
else
    val = sol.y_1+sol.y_2;
end

end

function val = get_obj_vector(sol, n_sol)

% objective
if n_sol==0
    val = NaN(2, 0);
else
    val = [sol.y_1 ; sol.y_2];
end

end

function var_param = get_var_param(integer)

var = {};
var{end+1} = struct('type', 'lin_float', 'name', 'x_1', 'v_1', 0, 'v_2', 3, 'n', 10, 'v_min', 0, 'v_max', 3);
var{end+1} = struct('type', 'log_float', 'name', 'x_2', 'v_1', 1, 'v_2', 3, 'n', 10, 'v_min', 1, 'v_max', 3);
if integer==true
    var{end+1} = struct('type', 'fixed', 'name', 'x_3', 'value', [5 7 9], 'set', [5 7 9]);
    var{end+1} = struct('type', 'scalar', 'name', 'x_4', 'value', 2);
else
    var{end+1} = struct('type', 'scalar', 'name', 'x_3', 'value', 5);
    var{end+1} = struct('type', 'scalar', 'name', 'x_4', 'value', 2);
end

var_param = struct('var', {var}, 'n_max', 100e3);

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
