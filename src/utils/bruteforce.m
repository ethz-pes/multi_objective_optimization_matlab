function [x, f_val, exitflag, output] = bruteforce(fct_optim, x0_mat, lb, ub, fct_con, options)

% number of points
n_sim = size(x0_mat, 1);
idx = true(n_sim, 1);

% boundary
lb = repmat(lb, n_sim, 1);
ub = repmat(ub, n_sim, 1);
[cnq, ceq] = fct_con(x0_mat);

if (~isempty(lb))
    idx = idx&all(x0_mat>=lb, 2);
end
if (~isempty(ub))
    idx = idx&all(x0_mat<=ub, 2);
end
if (~isempty(cnq))
    idx = idx&all(cnq<options.ConstraintToleranceInEq, 2);
end
if (~isempty(ceq))
    idx = idx&all(abs(cnq)<options.ConstraintToleranceEq, 2);
end

% select
x = x0_mat(idx,:);
n_valid = nnz(idx);

% compute
f_val = fct_optim(x);

% assign
output.n_sim = n_sim;
output.n_valid = n_valid;
if n_valid>0
    exitflag = +1;
else
    exitflag = -1;
end

end