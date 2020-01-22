function sol = get_solve_sol(x, fct_input, fct, n_split)
%GET_SOLVE_SOL Compute and return the solution of the problem.
%   val = GET_SOLVE_SOL(x, input, var_scale, fct_solve, fct_obj, n_split)
%   x - matrix containing the scaled points to be computed (matrix of float)
%   input - struct containing the constant (non-optimized) variables (struct of scalars)
%   var_scale - cell containing the function to unscale the variables (cell of struct)
%   fct_solve - function computing the solution from the inputs (function handle)
%   n_split - maximum number of solution evaluated in one vectorized call (integer)
%   sol - computed solution of the valid combinations (struct of arrays)
%   n_sol - number points contained in the solution (integer)
%
%   The following steps are computed:
%      - Unscale the variables to get the points to be computed
%      - Compute the points (parallel / vectorized), keeping only the valid desings
%
%   See also GET_SOLVE_RAW, GET_SOLVE_OBJ, GET_SOLUTION.

% parse and unscale the variable
disp('        get var')
[input, n_sweep] = fct_input(x);

if isnan(n_split)||(n_sweep<=n_split)
    % if too little points, compute the with parallel chunks
    disp(['        solve / ' num2str(n_sweep)])
    sol = fct(input, n_sweep);
else
    % divide the points into chunks
    disp(['        chunk / ' num2str(n_sweep)])
    [n_chunk, idx_chunk] = get_chunk(n_sweep, n_split);
    
    % parallel computing of the different chunks
    parfor i=1:n_chunk
        disp(['        ' num2str(i) ' / ' num2str(n_chunk)])
        out{i} = get_sol_vec(input, fct, idx_chunk{i});
    end
    
    % assemble the chunks together
    disp('        assemble')
    sol = get_struct_assemble(out);
end

end

function out_tmp = get_sol_vec(input, fct, idx_chunk)
%GET_SOL_VEC Compute the solution and check the validity for one chunk.
%   [sol, idx] = GET_SOL_VEC(input, sweep, fct_solve, idx))
%   input - struct containing the constant (non-optimized) variables (struct of scalars)
%   sweep - struct containing the optimized variables (struct of arrays)
%   fct_solve - function computing the solution from the inputs (function handle)
%   idx_chunk - indices of the combination to be computed (array of indices)
%   sol - computed solution of the valid combinations (struct of arrays)

% select the combination with respect to the chunk
input = get_struct_idx(input, idx_chunk);

% compute the solutions
out_tmp = fct(input, nnz(idx_chunk));

end