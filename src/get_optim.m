function data = get_optim(name, param)
%GET_OPTIM Solve a multi-objective optimization problem with different solver.
%   data = GET_OPTIM(name, param)
%   param - struct describing the problem and the solver (struct)
%      data.var_param - struct with the variable description (struct)
%      data.solver_name - string with the solver name (string)
%      data.solver_param - struct with the solver data (struct)
%   data - struct containing the solution (struct)
%      data.n_var - number of input variables used for the optimization (integer)
%      data.n_sweep - number of initial points used by the algorithm (integer)
%      data.n_sim - number of computed points during the optimization procedure (integer)
%      data.n_sol - number points contained in the solution (integer)
%      data.has_converged - return status of the algorithm (boolean)
%      data.info - information from the solver about the convergence (struct)
%      data.sol - solution data (struct of arrays)
%
%   For more information about data.var_param, see 'get_pre_proc'.
%   For more information about data.solver_name and data.solver_param, see 'get_solution'.
%
%   See also GET_PRE_PROC, GET_SOLUTION.

%   Thomas Guillod.
%   2020 - BSD License.

% init the simulation
disp(['============================= ' name])

% parse the optimization variables
disp('pre_proc')
[optim, n_var, n_sweep] = get_pre_proc(param.var_param);

% display the number of variables and initial points
disp('disp pre_proc')
disp(['    n_var = ' num2str(n_var)])
disp(['    n_sweep = ' num2str(n_sweep)])

% solve the optimization problem
disp('solution')
[sol, n_sol, n_sim, has_converged, info] = get_solution(param.solver_name, param.solver_param, optim);

% display the number of solution and some other information
disp('disp solution')
disp(['    n_var = ' num2str(n_var)])
disp(['    n_sweep = ' num2str(n_sweep)])
disp(['    n_sim = ' num2str(n_sim)])
disp(['    n_sol = ' num2str(n_sol)])
disp(['    has_converged = ' num2str(has_converged)])

% assign the results
data.n_var = n_var;
data.n_sweep = n_sweep;
data.n_sim = n_sim;
data.n_sol_valid = n_sol;
data.has_converged = has_converged;
data.info = info;
data.sol = sol;

end