function param = get_data(solver_name)

%% options
switch solver_name
    case 'bruteforce'
        var_param = get_var_param(true);
        
        options = struct('ConstraintToleranceEq', 1e-3, 'ConstraintToleranceInEq', 1e-3);
        solver_param = get_solr_param(false, options);
    case 'ga'
        var_param = get_var_param(true);
        
        options = optimoptions (@ga);
        options = optimoptions(options, 'TolFun', 1e-6);
        options = optimoptions(options, 'ConstraintTolerance', 1e-3);
        options = optimoptions(options, 'Generations', 20);
        options = optimoptions(options, 'PopulationSize', 2000);
        solver_param = get_solr_param(false, options);
    case 'gamultiobj'
        var_param = get_var_param(false);
        
        options = optimoptions(@gamultiobj);
        options = optimoptions(options, 'TolFun', 1e-6);
        options = optimoptions(options, 'ConstraintTolerance', 1e-3);
        options = optimoptions(options, 'Generations', 20);
        options = optimoptions(options, 'PopulationSize', 700);
        solver_param = get_solr_param(true, options);
    otherwise
        error('invalid solver_name')
end

% assign
param.solver_param = solver_param;
param.var_param = var_param;
param.solver_name = solver_name;

end

function solver_param = get_solr_param(vector, options)

solver_param.n_split = 500;
solver_param.options = options;
solver_param.fct_output = @get_output;
solver_param.fct_con_c = @get_con_c;
solver_param.fct_con_ceq = @get_con_ceq;

if vector==true
    solver_param.fct_obj = @get_obj_vector;
else
    solver_param.fct_obj = @get_obj_scalar;
end

end

function var_param = get_var_param(integer)

var = {};
var{end+1} = struct('type', 'float', 'name', 'x_1', 'scale', 'lin', 'vec', linspace(0, 3, 25), 'lb', 0.0, 'ub', 3.0);
var{end+1} = struct('type', 'float', 'name', 'x_2', 'scale', 'log', 'vec', logspace(log10(1), log10(3), 25), 'lb', 1.0, 'ub', 3.0);
if integer==true
    var{end+1} = struct('type', 'integer', 'name', 'x_3','vec', [5 7 9], 'set', [5 7 9]);
    var{end+1} = struct('type', 'scalar', 'name', 'x_4', 'v', 2);
else
    var{end+1} = struct('type', 'scalar', 'name', 'x_3', 'v', 5);
    var{end+1} = struct('type', 'scalar', 'name', 'x_4', 'v', 2);
end

var_param = struct('var', {var}, 'n_max', 100e3, 'fct_select', @(input, n_size) true(1, n_size));

end

function c = get_con_c(input, n_size)

[y_1, y_2] = get_raw(input);
c = [y_1-10 ; y_2-10];

end

function ceq = get_con_ceq(input, n_size)

ceq = [];

end


function fval = get_obj_scalar(input, n_size)

[y_1, y_2] = get_raw(input);
fval = y_1+y_2;

end

function fval = get_obj_vector(input, n_size)

[y_1, y_2] = get_raw(input);
fval = [y_1 ; y_2];

end

function sol = get_output(input, n_size)

[y_1, y_2] = get_raw(input);
sol.y_1 = y_1;
sol.y_2 = y_2;

end

function [y_1, y_2] = get_raw(input)

% assign
x_1 = input.x_1;
x_2 = input.x_2;
x_3 = input.x_3;
x_4 = input.x_4;

% compute
y_1 = x_1.^2+x_2.^2+x_3;
y_2 = 0.5*((x_1-2).^2+(x_2+1).^2)+2+x_4;

end
