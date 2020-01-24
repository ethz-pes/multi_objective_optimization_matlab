function [optim, n_var, n_init] = get_pre_proc(var_param)
%GET_PRE_PROC Parse and scale the input variables, generates the initial points.
%   [optim, n_var, n_init] = GET_PRE_PROC(var_param)
%   var_param - struct with the variable description (struct)
%      data.n_max - maximum number of initial points for avoid out of memory crashes (integer)
%      data.fct_select - check if the generated iniitial points should be included (function handle)
%         idx = fct_select(input, n_size)
%         input - parsed and scaled input points (struct of arrays)
%         n_size - number of points (integer)
%         idx - indices to be selected (array of indices or array of logical)
%      data.var - cell of struct with the different variable description (cell of struct)
%          data.var{i}.type - type of the variable (string containing 'lin_float')
%          data.var{i}.name - name of the variable (string)
%          data.var{i} - description of a float variable with linear scale (type is 'float')
%              data.var{i}.scale - scaling of the variable (string)
%                  'lin' - no scaling is performed
%                  'log' - log10(x) scaling of the variable
%                  'exp' - 10^x scaling of the variable
%                  'square' - x^2 scaling of the variable
%                  'sqrt' - sqrt(x) scaling of the variable
%              data.var{i}.lb - lower boundary for the variable (float)
%              data.var{i}.ub - upper boundary for the variable (float)
%              data.var{i}.vec - vector with the values for the initial points (vector of floats)
%          data.var{i} - description of an integer variable (type is 'integer')
%              data.var{i}.set - integer with the set of possible values (array of integer)
%              data.var{i}.vec - integer with the initial combinations (array of integer)
%          data.var{i} - description of a constant (non-optimized) variable (type is 'scalar')
%              data.var{i}.v - value of the single constant variable (float)
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
%   n_var - number of input variables used for the optimization (integer)
%   n_init - number of initial points used by the algorithm (integer)
%
%   This function performs the following tasks on the variables:
%      - Find the lower and upper bounds
%      - Find the integer variables
%      - Find the constant variables
%      - Spanning the initial points
%      - Filtering the valid initial points
%      - Scaling the variables:
%         - Scale the 'float' variables with 'lin', 'log', 'exp', 'square', or 'sqrt'
%         - Mapping integer variables from [x1, x1, ..., xn] to [1, 2, ..., n]
%
%   See also GET_MULTI_OBJ_OPT, GET_SOLUTION.

%   Thomas Guillod.
%   2020 - BSD License.

% extract the provided data
var = var_param.var;
n_max = var_param.n_max;
fct_select = var_param.fct_select;

% init the output
var_scale = {};
lb = [];
int_con = [];
ub = [];
x0_cell = {};
var_cst = struct();

% parse the different variable
for i=1:length(var)
    var_tmp = var{i};
    
    switch var_tmp.type
        case 'scalar'
            % scalar variable should not be array, assign them to the input struct
            assert(length(var_tmp.v)==1, 'invalid length')
            var_cst.(var_tmp.name) = var_tmp.v;
        case 'integer'
            % check that the initial points respect the set
            assert(length(var_tmp.set)>1, 'invalid length')
            assert(all(ismember(var_tmp.vec, var_tmp.set)), 'invalid initial vector')
            
            % get the scaling function
            [fct_scale, fct_unscale] = get_scale('integer');

            % mapping integer variables from [x1, x1, ..., xn] to [1, 2, ..., n]
            var_scale{end+1} = struct('name', var_tmp.name, 'fct_unscale',  @(x) fct_unscale(var_tmp.set, x));
            x0_cell{end+1} = fct_scale(var_tmp.set, var_tmp.vec);
            
            % flag the integer variable
            int_con(end+1) = length(var_scale);
                        
            % set the bounds in the transformed coordinates
            lb(end+1) = min(fct_scale(var_tmp.set, var_tmp.set));
            ub(end+1) = max(fct_scale(var_tmp.set, var_tmp.set));
        case 'float'
            % check that the initial points respect the bounds
            assert(var_tmp.ub>=var_tmp.lb, 'invalid length')
            assert(all(var_tmp.vec>=var_tmp.lb)&&all(var_tmp.vec<=var_tmp.ub), 'invalid initial vector')
            
            % get the scaling function
            [fct_scale, fct_unscale] = get_scale(var_tmp.scale);
            
            % set the scaled variable
            var_scale{end+1} = struct('name', var_tmp.name, 'fct_unscale', fct_unscale);
            x0_cell{end+1} = fct_scale(var_tmp.vec);
            
            % set the bounds
            lb(end+1) = fct_scale(var_tmp.lb);
            ub(end+1) = fct_scale(var_tmp.ub);
        otherwise
            error('invalid type')
    end
end

% function creating the input struct from the scaled variables
fct_input = @(x) get_input(x, var_cst, var_scale);

% get the size of the variable
[n_var, n_init] = get_size(x0_cell, n_max);

% span all the combinations between the initial points and filter them
x0 = get_x0(x0_cell, fct_input, fct_select);

% assign the data
optim.fct_input = fct_input;
optim.lb = lb;
optim.ub = ub;
optim.int_con = int_con;
optim.x0 = x0;

end

function [fct_scale, fct_unscale] = get_scale(scale)
%GET_SCALE Get the scaling and unscaling function.
%   [fct_scale, fct_unscale] = GET_SCALE(scale)
%   scale - type of the scaling to be done (string)
%   fct_scale - function to scale the variable (function handle)
%   fct_unscale - function to unscale the variable (function handle)

switch scale
    case 'integer'
        fct_scale = @(set, vec) find(ismember(set, vec));
        fct_unscale = @(set, vec) set(vec);
    case 'lin'
        fct_scale = @(x) x;
        fct_unscale = @(x) x;
    case 'log'
        fct_scale = @(x) log10(x);
        fct_unscale = @(x) 10.^x;
    case 'exp'
        fct_scale = @(x) 10.^x;
        fct_unscale = @(x) log10(x);
    case 'square'
        fct_scale = @(x) x.^2;
        fct_unscale = @(x) sqrt(x);
    case 'sqrt'
        fct_scale = @(x) sqrt(x);
        fct_unscale = @(x) x.^2;
    otherwise
        error('invalid scale')
end

end

function [input, n_size] = get_input(x, var_cst, var_scale)
%GET_INPUT Get the input struct from the scaled variable matrix.
%   [input, n_size] = GET_INPUT(x, input, var_scale)
%   x - matrix containing the scaled points to be computed (matrix of float)
%   var_cst - struct containg the constant variables (struct of scalars)
%   var_scale - cell containing the function to unscale the variables (cell of struct)
%   input - parsed and scaled input points (struct of arrays)
%   n_size - number of points (integer)

% get the number of points
n_size = size(x, 1);

% unscaled the variable
for i=1:length(var_scale)
    % extract the data
    name = var_scale{i}.name;
    fct_unscale = var_scale{i}.fct_unscale;
    
    % select the variable and unscale
    x_tmp = x(:,i).';
    sweep.(name) = fct_unscale(x_tmp);
end

% extend the constant variable to the chunk size
var_cst = get_struct_size(var_cst, n_size);

% merge the optimized and constant variables
field = [fieldnames(var_cst) ; fieldnames(sweep)];
value = [struct2cell(var_cst) ; struct2cell(sweep)];
input = cell2struct(value, field);

end

function [n_var, n_init] = get_size(x0_cell, n_max)
%GET_SIZE Get and check the number of initial points.
%   [n_var, n_init] = GET_SIZE(x0_cell, n_max)
%   x0_cell - initial points of the different variables (cell of float arrays)
%   n_max - maximum number of initial points for avoid out of memory crashes (integer)
%   n_var - number of input variables used for the optimization (integer)
%   n_init - number of initial points used by the algorithm (integer)

% all the combinations between the initial points
n_init = prod(cellfun(@length, x0_cell));
n_init = max(1, n_init);
assert(n_init<=n_max, 'invalid length');
assert(n_init>0, 'invalid length');

% number of optimization variables
n_var = length(x0_cell);
assert(n_var>0, 'invalid length');

end

function x0 = get_x0(x0_cell, fct_input, fct_select)
%GET_X0 Span all the combinations between the initial points and filter them.
%   x0 = GET_X0(x0_cell)
%   x0_cell - initial points of the different variables (cell of float arrays)
%   fct_input - function creating the input struct from the scaled variables (function handle)
%   fct_select - check if the generated iniitial points should be included (function handle)
%   x0 - matrix containing the scaled initial points (matrix of float)

% get all the combinations
x0_tmp = cell(1,length(x0_cell));
[x0_tmp{:}] = ndgrid(x0_cell{:});
for i=1:length(x0_tmp)
    x0(:,i) = x0_tmp{i}(:);
end

% filter the combinations
[input, n_init] = fct_input(x0);
idx_select = fct_select(input, n_init);
x0 = x0(idx_select, :);

end