function run_example()
%RUN_EXAMPLE Run an example of multi-ojective optimization with different solvers.
%
%   The description of the problem can be found in 'get_data'.
%
%   See also GET_OPTIM, GET_DATA.

%   Thomas Guillod.
%   2020 - BSD License.

close('all')
addpath(genpath('src'))

%% solve brute force optimization
[var_param, solver_param] = get_data('bruteforce');
data_bruteforce = get_optim('bruteforce', var_param, solver_param);

%% solve single-objective optimization with genetic algorithm
[var_param, solver_param] = get_data('ga');
data_ga = get_optim('ga', var_param, solver_param);

%% solve multi-objective optimization with genetic algorithm
[var_param, solver_param] = get_data('gamultiobj');
data_gamultiobj = get_optim('gamultiobj', var_param, solver_param);

%% plot the results
figure()
plot(data_bruteforce.sol.output.y_1, data_bruteforce.sol.output.y_2, 'xb')
hold('on')
plot(data_gamultiobj.sol.output.y_1, data_gamultiobj.sol.output.y_2, 'dr')
plot(data_ga.sol.output.y_1, data_ga.sol.output.y_2, 'og', 'markerfacecolor', 'g')
grid('on')
xlabel('y_{1}')
ylabel('y_{2}')
legend('bruteforce', 'gamultiobj', 'ga')
title('Multi-Objective Optimization')

end

