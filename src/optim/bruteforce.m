function [x, fval, exitflag, output] = bruteforce(fct_obj, x0, lb, ub, fct_con, options)
%BRUTEFORCE Brute force grid search optimization algorithm.
%   [x, fval, exitflag, output] = BRUTEFORCE(fct_obj, x0, lb, ub, fct_con, options)
%   fct_obj - objective function for the optimization  (function handle)
%      fval = fct_obj(x)
%      x - input points (matrix)
%      fval - objective function values (matrix or array)
%   x0 - input points to be considered (matrix)
%   lb - lower bound for the different variables (array or empty)
%   ub - upper bound for the different variables (array or empty)
%   fct_con - function with equalities and inequalities constraints (function handle)
%      [c, ceq] = fct_con(x0)
%      x - input points (matrix)
%      c - inequalities contraints, c<0 (matrix or array or empty)
%      ceq - equalities contraints, c==0 (matrix or array or empty)
%   options - strut with the tolerances on the constraints (struct)
%      options.ConstraintToleranceInEq - tolerance for inequalities (float)
%      options.ConstraintToleranceEq - tolerance for equalities (float)
%   x - output valid points (matrix)
%   fval - objective function values of the valid points (matrix or array)
%   exitflag - return status of the solver (integer)
%      1 - valid points are found
%      0 - no valid points
%   output - struct with information about the solver (struct)
%      options.n_sim - number of input points (integer)
%      options.n_valid - number of valid points (integer)
%
%   This solver works with vectorized data:
%      - n_col - number of variables
%      - n_row - number of points
%
%   The input and output arguments are strange for a brute force solver.
%   This has been done in order to have similar arguments as the MATLAB optimization toolbox.
%
%   (c) 2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% number of points
n_sim = size(x0, 1);

% compute constraints
lb = repmat(lb, n_sim, 1);
ub = repmat(ub, n_sim, 1);
[c, ceq] = fct_con(x0);

% extract the valid points
idx = true(n_sim, 1);
if (~isempty(lb))
    idx = idx&all(x0>=lb, 2);
end
if (~isempty(ub))
    idx = idx&all(x0<=ub, 2);
end
if (~isempty(c))
    idx = idx&all(c<options.ConstraintToleranceInEq, 2);
end
if (~isempty(ceq))
    idx = idx&all(abs(ceq)<options.ConstraintToleranceEq, 2);
end

% select the valid points
x = x0(idx,:);
n_valid = nnz(idx);

% compute the objective
fval = fct_obj(x);

% assign
output.n_sim = n_sim;
output.n_valid = n_valid;
exitflag = double(n_valid>0);

end