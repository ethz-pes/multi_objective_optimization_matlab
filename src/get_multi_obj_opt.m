function data = get_multi_obj_opt(name, var_param, solver_param)
%GET_MULTI_OBJ_OPT Solve a multi-objective optimization problem with different solvers.
%   data = GET_MULTI_OBJ_OPT(name, var_param, solver_param)
%   name - name of the problem (string)
%   var_param - struct with the variable description (struct)
%   solver_param - struct with the solver data (struct)
%   data - struct containing the solution (struct)
%      data.n_var - number of input variables used for the optimization (integer)
%      data.n_init - number of initial points used by the algorithm (integer)
%      data.n_sol - number points contained in the solution (integer)
%      data.has_converged - return status of the algorithm (boolean)
%      data.info - information from the solver about the convergence (struct)
%         data.info.output - struct with information about the solver (struct)
%         data.info.exitflag - return status of the solver (integer)
%      data.sol - solution data (struct)
%         data.sol.fval - values of the objective function (array of matrix)
%         data.sol.input - struct with the valid points (struct of arrays)
%         data.sol.output - struct with the generated output (struct of arrays)
%
%   For more information about 'data.var_param', see 'get_pre_proc'.
%   For more information about 'data.solver_param', see 'get_solution'.
%
%   This multi-objective optimization works in two steps:
%      - 'get_pre_proc' - extract and scale the variables, get the intial points
%      - 'get_solution' - solve the problem with different solvers
%
%   The following solver are currently implemented:
%      - 'bruteforce' - check and the intial points and nothing else
%      - 'ga' - single-objective genetic optimization
%      - 'gamultiobj' - multi-objective genetic optimization
%
%   See also GET_PRE_PROC, GET_SOLUTION.
%
%   (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% init the simulation
disp(['============================= ' name])

% parse the optimization variables
disp('pre_proc')
[optim, n_var, n_init] = get_pre_proc(var_param);

% display the number of variables and initial points
disp('disp pre_proc')
disp(['    n_var = ' num2str(n_var)])
disp(['    n_init = ' num2str(n_init)])

% solve the optimization problem
disp('solution')
[sol, n_sol, has_converged, info] = get_solution(solver_param, optim);

% display the number of solution and some other information
disp('disp solution')
disp(['    n_var = ' num2str(n_var)])
disp(['    n_init = ' num2str(n_init)])
disp(['    n_sol = ' num2str(n_sol)])
disp(['    has_converged = ' num2str(has_converged)])

% assign the results
data.n_var = n_var;
data.n_init = n_init;
data.n_sol = n_sol;
data.has_converged = has_converged;
data.info = info;
data.sol = sol;

end