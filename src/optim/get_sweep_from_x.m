function [sweep, n_sweep] = get_sweep_from_x(x, var_scale)

n_sweep = size(x, 1);

for i=1:length(var_scale)
    name = var_scale{i}.name;
    fct_unscale = var_scale{i}.fct_unscale;
    x_tmp = x(:,i).';
    sweep.(name) = fct_unscale(x_tmp);
end

end
