function [sweep, n_sweep] = get_sweep_from_x(x, var_scale)
%GET_SWEEP_FROM_X Parse and unscale the optimized variables.
%   [sweep, n_sweep] = GET_SWEEP_FROM_X(x, var_scale)
%   x - matrix containing the scaled points to be computed (matrix of float)
%   var_scale - cell containing the function to unscale the variables (cell of struct)
%   sweep - struct containing the scaled variables to be optimized (struct of arrays)
%   n_sweep - number of solutions to be computed (integer)
%
%   See also GET_SOLVE_OBJ, GET_SOLVE_SOL, GET_SOLUTION.

% get the number of points
n_sweep = size(x, 1);

% unscaled the variable
for i=1:length(var_scale)
    % extract the data
    name = var_scale{i}.name;
    fct_unscale = var_scale{i}.fct_unscale;
    
    % select the variable and unscale
    x_tmp = x(:,i).';
    sweep.(name) = fct_unscale(x_tmp);
end

end
