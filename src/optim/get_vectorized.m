function sol = get_vectorized(x, fct_input, fct_sol, n_split)
%GET_VECTORIZED Compute a function with parallel and vectorized evaluation.
%   sol = GET_VECTORIZED(x, fct_input, fct_sol, n_split)
%   x - input points to be evaluated (matrix)
%   fct_input - input points to be evaluated (function handle)
%      [input, n_size] = fct_input(x)
%      x - input points to be evaluated (matrix)
%      input - parsed and scaled input points (struct of arrays)
%      n_size - number of points (integer)
%   fct_sol - compute the solution from the input (function handle)
%      sol = fct_sol(input, n_size);
%      input - parsed and scaled input points (struct of arrays)
%      n_size - number of points (integer)
%      sol - computed solution (matrix or array or struct of arrays)
%   n_split - maximum number of solution evaluated in one vectorized call (integer)
%   sol - computed solution (matrix or array or struct of arrays)
%
%   The following steps are computed:
%      - Unscale the variables to get the points to be computed with 'fct_input'
%      - Split the points into chunks for parallel evaluation
%      - Compute the points (parallel / vectorized) with 'fct_sol'
%      - Assemble the different chunks together
%
%   See also GET_SOLUTION, GET_CHUNK.
%
%   (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% parse and unscale the variable
disp('        get var')
[input, n_size] = fct_input(x);

if isnan(n_split)||(n_size<=n_split)
    % if too little points, compute without parallel chunks
    disp(['        solve / ' num2str(n_size)])
    sol = fct_sol(input, n_size);
else
    % divide the points into chunks
    disp(['        chunk / ' num2str(n_size)])
    [n_chunk, idx_chunk] = get_chunk(n_size, n_split);
    
    % parallel computing of the different chunks
    parfor i=1:n_chunk
        disp(['        ' num2str(i) ' / ' num2str(n_chunk)])
        sol{i} = get_sol_vec(input, fct_sol, idx_chunk{i});
    end
    
    % assemble the chunks together
    disp('        assemble')
    sol = [sol{:}];
    if isstruct(sol)
        sol = get_struct_assemble(sol, n_size);
    else
        assert(isnumeric(sol)||islogical(sol), 'invalid type')
        assert((size(sol, 2)==n_size)||isempty(sol), 'invalid size')
    end
end

end

function sol = get_sol_vec(input, fct_sol, idx_chunk)
%GET_SOL_VEC Compute the solution for a specific chunk.
%   sol = GET_SOL_VEC(input, fct_sol, idx_chunk))
%   input - parsed and scaled input points (struct of arrays)
%   fct_sol - compute the solution from the input (function handle)
%   idx_chunk - indices of the combination to be computed (array of indices)
%   sol - computed solution (matrix or array or struct of arrays)

% select the combination with respect to the chunk
input = get_struct_idx(input, idx_chunk);

% compute the solutions
sol = fct_sol(input, nnz(idx_chunk));

end