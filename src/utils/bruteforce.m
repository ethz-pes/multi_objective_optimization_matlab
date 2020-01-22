function [x, f_val, exitflag, output] = bruteforce(fct_optim, x0_mat, lb, ub, fct_con, options)

f_val = fct_optim(x0_mat);
[cnq, ceq] = fct_con(x0_mat);

keyboard


end