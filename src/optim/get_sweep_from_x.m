function [sweep, n_sweep] = get_sweep_from_x(x, var_optim)

n_sweep = size(x, 1);

for i=1:length(var_optim)
    name = var_optim{i}.name;
    fct_scale = var_optim{i}.fct_scale;
    x_tmp = x(:,i).';
    sweep.(name) = fct_scale(x_tmp);
end

end
