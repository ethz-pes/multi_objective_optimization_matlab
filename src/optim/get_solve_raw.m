function sol = get_solve_raw(input, sweep, fct_solve, n_split, n_sweep)
%GET_SOLVE_RAW Compute the solution (parallel / vectorized) and check validity.
%   [sol, idx] = GET_SOLVE_RAW(input, sweep, fct_solve, n_split, n_sweep)
%   input - struct containing the constant (non-optimized) variables (struct of scalars)
%   sweep - struct containing the scaled variables to be optimized (struct of arrays)
%   fct_solve - function computing the solution from the inputs (function handle)
%   n_split - maximum number of solution evaluated in one vectorized call (integer)
%   n_sweep - number of solutions to be computed (integer)
%   sol - computed solution of the valid combinations (struct of arrays)
%
%   See also GET_SOLVE_OBJ, GET_SOLVE_SOL, GET_SOLUTION.

if isnan(n_split)||(n_sweep<=n_split)
    % if too little points, compute the with parallel chunks
    disp(['        solve / ' num2str(n_sweep)])
    sol = get_sol_vec(input, sweep, fct_solve, 1:n_sweep);
else
    % divide the points into chunks
    disp(['        chunk / ' num2str(n_sweep)])
    [n_chunk, idx_chunk] = get_chunk(n_sweep, n_split);
    
    % parallel computing of the different chunks
    parfor i=1:n_chunk
        disp(['        ' num2str(i) ' / ' num2str(n_chunk)])
        sol(i) = get_sol_vec(input, sweep, fct_solve, idx_chunk{i});
    end
    
    % assemble the chunks together
    disp('        assemble')
    sol = get_struct_assemble(sol);
end

end

function sol = get_sol_vec(input, sweep, fct_solve, idx_chunk)
%GET_SOL_VEC Compute the solution and check the validity for one chunk.
%   [sol, idx] = GET_SOL_VEC(input, sweep, fct_solve, idx))
%   input - struct containing the constant (non-optimized) variables (struct of scalars)
%   sweep - struct containing the optimized variables (struct of arrays)
%   fct_solve - function computing the solution from the inputs (function handle)
%   idx_chunk - indices of the combination to be computed (array of indices)
%   sol - computed solution of the valid combinations (struct of arrays)

% select the combination with respect to the chunk
sweep = get_struct_idx(sweep, idx_chunk);

% extend the constant variable to the chunk size
input = get_struct_size(input, nnz(idx_chunk));

% merge the optimized and constant variables
field = [fieldnames(input) ; fieldnames(sweep)];
value = [struct2cell(input) ; struct2cell(sweep)];
input = cell2struct(value, field);

% compute the solutions
sol = fct_solve(input, nnz(idx_chunk));

end