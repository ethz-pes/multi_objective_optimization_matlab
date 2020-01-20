function [optim, n_var, n_sweep] = get_pre_proc(var_param)

% extract
var = var_param.var;
n_max = var_param.n_max;

% init
var_optim = {};
lb = [];
int_con = [];
ub = [];
x0_cell = {};
input = struct();

% fill
for i=1:length(var)
    var_tmp = var{i};
    
    switch var_tmp.type
        case 'scalar'
            assert(length(var_tmp.value)==1, 'invalid data')
            input.(var_tmp.name) = var_tmp.value;
        case 'fixed'
            assert(all(ismember(var_tmp.value, var_tmp.set)), 'invalid data')
            var_optim{end+1} = struct('name', var_tmp.name, 'fct_scale',  @(x) get_integer_map(1:length(var_tmp.set), var_tmp.set, x));
            x0_cell{end+1} = get_integer_map(var_tmp.set, 1:length(var_tmp.set), var_tmp.value);
            lb(end+1) = 1;
            ub(end+1) = length(var_tmp.set);
            int_con(end+1) = length(var_optim);
        case 'log_float'
            assert(var_tmp.v_1>=var_tmp.v_min, 'invalid data')
            assert(var_tmp.v_2<=var_tmp.v_max, 'invalid data')
            var_optim{end+1} = struct('name', var_tmp.name, 'fct_scale', @(x) 10.^x);
            x0_cell{end+1} = log10(logspace(log10(var_tmp.v_1), log10(var_tmp.v_2), var_tmp.n));
            lb(end+1) = log10(var_tmp.v_min);
            ub(end+1) = log10(var_tmp.v_max);
        case 'lin_float'
            assert(var_tmp.v_1>=var_tmp.v_min, 'invalid data')
            assert(var_tmp.v_2<=var_tmp.v_max, 'invalid data')
            var_optim{end+1} = struct('name', var_tmp.name, 'fct_scale', @(x) x);
            x0_cell{end+1} = linspace(var_tmp.v_1, var_tmp.v_2, var_tmp.n);
            lb(end+1) = var_tmp.v_min;
            ub(end+1) = var_tmp.v_max;
        otherwise
            error('invalid data')
    end
end

% size
[n_sweep, n_var] = get_size(x0_cell, n_max);

[x0, sweep] = get_sweep(var_optim, x0_cell);

% optim
optim.var_optim = var_optim;
optim.lb = lb;
optim.ub = ub;
optim.int_con = int_con;
optim.x0 = x0;
optim.sweep = sweep;
optim.input = input;

end

function [n_sweep, n_var] = get_size(x0_cell, n_max)

n_sweep = prod(cellfun(@length, x0_cell));
n_sweep = max(1, n_sweep);
n_var = length(x0_cell);
assert(n_sweep<=n_max, 'invalid data');

end

function [x0, sweep] = get_sweep(var_optim, x0_cell)

if isempty(var_optim)
    x0 = [];
    sweep = struct();
else
    x0_mat = cell(1,length(x0_cell));
    [x0_mat{:}] = ndgrid(x0_cell{:});
    for i=1:length(x0_mat)
        x0(:,i) = x0_mat{i}(:);
    end
    
    % get the sweep
    for i=1:length(var_optim)
        name = var_optim{i}.name;
        fct_scale = var_optim{i}.fct_scale;
        vec = x0(:,i).';
        sweep.(name) = fct_scale(vec);
    end
end

end