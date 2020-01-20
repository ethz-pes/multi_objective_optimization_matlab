function [sol, idx] = get_solve_raw(input, sweep, fct_solve, fct_valid, n_split, n_sweep)

if isnan(n_split)||(n_sweep<=n_split)
    disp('    solve')
    [sol, idx] = get_sol_vec(input, sweep, fct_solve, fct_valid, 1:n_sweep);
else
    disp('    chunk')
    
    [n_chunk, idx_chunk] = get_chunk(n_sweep, n_split);
    
    parfor i=1:n_chunk
        disp(['    ' num2str(i) ' / ' num2str(n_chunk)])
        [sol(i), idx{i}] = get_sol_vec(input, sweep, fct_solve, fct_valid, idx_chunk{i});
    end
    
    disp('    assemble')
    idx = [idx{:}];
    sol = get_struct_assemble(sol);
end

end

function [sol, idx] = get_sol_vec(input, sweep, fct_solve, fct_valid, idx)

sweep = get_struct_idx(sweep, idx);
input = get_struct_size(input, length(idx));

% merge struct
field = [fieldnames(input) ; fieldnames(sweep)];
value = [struct2cell(input) ; struct2cell(sweep)];
input = cell2struct(value, field);

% compute
sol = fct_solve(input, length(idx));

% filter
idx = fct_valid(sol, length(idx));
sol = get_struct_idx(sol, idx);

end