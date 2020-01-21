function [optim, n_var, n_sweep] = get_pre_proc(var_param)
%GET_PRE_PROC Parse and scale the input variables, generates the initial points.
%   [optim, n_var, n_sweep] = GET_PRE_PROC(var_param)
%   var_param - struct with the variable description (struct)
%      data.n_max - maximum number of initial points for avoid out of memory crashed (integer)
%      data.var - cell of struct with the different variable description (cell of struct)
%          data.var{i}.type - type of the variable (string containing 'lin_float')
%          data.var{i}.name - name of the variable (string)
%          data.var{i} - description of a float variable with linear scale (type is 'lin_float')
%              data.var{i}.lb - lower boundary for the variable (float)
%              data.var{i}.ub - upper boundary for the variable (float)
%              data.var{i}.v_1 - lower boundary for the initial points (float)
%              data.var{i}.v_2 - upper boundary for the initial points (float)
%              data.var{i}.n - number of initial points (integer)
%          data.var{i} - description of a float variable with logarithmic scale (type is 'log_float')
%              data.var{i}.lb - lower boundary for the variable (float)
%              data.var{i}.ub - upper boundary for the variable (float)
%              data.var{i}.v_1 - lower boundary for the initial points (float)
%              data.var{i}.v_2 - upper boundary for the initial points (float)
%              data.var{i}.n - number of initial points (integer)
%          data.var{i} - description of an integer variable (type is 'integer')
%              data.var{i}.set - integer with the set of possible values (array of integer)
%              data.var{i}.value - integer with the initial combinations (array of integer)
%          data.var{i} - description of a constant (non-optimized) variable (type is 'scalar')
%              data.var{i}.value - value of the constant variable (scalar)
%   optim - struct with the parsed variables (struct)
%      optim.lb - array containing the lower bounds of the variables (array of float)
%      optim.ub - array containing the upper bounds of the variables (array of float)
%      optim.int_con - array containing the index of the integer variables (array of integer)
%      optim.input - struct containing the constant (non-optimized) variables (array of integer)
%      optim.x0 - matrix containing the scaled initial points (matrix of float)
%      optim.var_scale - cell containing the function to unscale the variables (cell of struct)
%         optim.var_scale{i}.name - name of the variable (string)
%         optim.var_scale{i}.fct_unscale - function for unscaling the variables (function handle)
%   n_var - number of input variables used for the optimization (integer)
%   n_sweep - number of initial points used by the algorithm (integer)
%
%   This function performs the following tasks on the variables:
%      - Find the lower and upper bounds
%      - Find the integer variables
%      - Find the constant variables
%      - Spanning the initial points
%      - Scaling the integer:
%         - Doing nothing for 'lin_float' variables
%         - Optimizing with the log of the given variable for 'log_float' variables
%         - Mapping integer variables from [x1, x1, ..., xn] to [1, 2, ..., n]
%
%   See also GET_OPTIM, GET_SOLUTION.

%   Thomas Guillod.
%   2020 - BSD License.


% extract the provided data
var = var_param.var;
n_max = var_param.n_max;

% init the output
var_scale = {};
lb = [];
int_con = [];
ub = [];
x0_cell = {};
input = struct();

% parse the different variable
for i=1:length(var)
    var_tmp = var{i};
    
    switch var_tmp.type
        case 'scalar'
            % scalar variable should not be array, assign them to the input struct
            assert(length(var_tmp.value)==1, 'invalid data')
            input.(var_tmp.name) = var_tmp.value;
        case 'integer'
            % check that the initial points respect the set
            assert(all(ismember(var_tmp.value, var_tmp.set)), 'invalid data')
            assert(length(var_tmp.set)>1, 'invalid data')
            
            % mapping integer variables from [x1, x1, ..., xn] to [1, 2, ..., n]
            var_scale{end+1} = struct('name', var_tmp.name, 'fct_unscale',  @(x) var_tmp.set(x));
            x0_cell{end+1} = find(ismember(var_tmp.set, var_tmp.value));
            
            % flag the integer variable
            int_con(end+1) = length(var_scale);
            
            % set the bounds in the transformed coordinates
            lb(end+1) = 1;
            ub(end+1) = length(var_tmp.set);
        case 'lin_float'
            % check that the initial points respect the bounds
            assert(var_tmp.v_1>=var_tmp.lb, 'invalid data')
            assert(var_tmp.v_2<=var_tmp.ub, 'invalid data')
            assert(var_tmp.ub>=var_tmp.lb, 'invalid data')
            
            % no variable transformation, generate the initial points
            var_scale{end+1} = struct('name', var_tmp.name, 'fct_unscale', @(x) x);
            x0_cell{end+1} = linspace(var_tmp.v_1, var_tmp.v_2, var_tmp.n);
            
            % set the bounds
            lb(end+1) = var_tmp.lb;
            ub(end+1) = var_tmp.ub;
            
        case 'log_float'
            % check that the initial points respect the bounds
            assert(var_tmp.v_1>=var_tmp.lb, 'invalid data')
            assert(var_tmp.v_2<=var_tmp.ub, 'invalid data')
            assert(var_tmp.ub>=var_tmp.lb, 'invalid data')

            % log variable transformation, generate the initial points
            var_scale{end+1} = struct('name', var_tmp.name, 'fct_unscale', @(x) 10.^x);
            x0_cell{end+1} = log10(logspace(log10(var_tmp.v_1), log10(var_tmp.v_2), var_tmp.n));
            
            % set the bounds in the transformed coordinates
            lb(end+1) = log10(var_tmp.lb);
            ub(end+1) = log10(var_tmp.ub);
        otherwise
            error('invalid data')
    end
end

% get the size of the variable
[n_var, n_sweep] = get_size(x0_cell, n_max);

% span all the combinations between the initial points
x0 = get_x0(x0_cell);

% assign the data
optim.var_scale = var_scale;
optim.lb = lb;
optim.ub = ub;
optim.int_con = int_con;
optim.x0 = x0;
optim.input = input;

end

function [n_var, n_sweep] = get_size(x0_cell, n_max)
%GET_SIZE Get and check the number of initial points.
%   [n_var, n_sweep] = GET_SIZE(x0_cell, n_max)
%   x0_cell - initial points of the different variables (cell of float array)
%   n_max - maximum number of initial points for avoid out of memory crashed (integer)
%   n_var - number of input variables used for the optimization (integer)
%   n_sweep - number of initial points used by the algorithm (integer)

% all the combinations between the initial points
n_sweep = prod(cellfun(@length, x0_cell));
n_sweep = max(1, n_sweep);
assert(n_sweep<=n_max, 'invalid data');

% number of optimization variables
n_var = length(x0_cell);

end

function x0 = get_x0(x0_cell)
%GET_X0 Span all the combinations between the initial points.
%   x0 = GET_X0(x0_cell)
%   x0_cell - initial points of the different variables (cell of float array)
%   x0 - matrix containing the scaled initial points (matrix of float)

if isempty(x0_cell)
    x0 = [];
else
    x0_mat = cell(1,length(x0_cell));
    [x0_mat{:}] = ndgrid(x0_cell{:});
    for i=1:length(x0_mat)
        x0(:,i) = x0_mat{i}(:);
    end
end

end