function run_example()
%RUN_EXAMPLE Run an example of multi-ojective optimization with different solvers.
%
%   The description of the problem can be found in 'get_data'.
%
%   See also GET_MULTI_OBJ_OPT, GET_DATA.

%   Thomas Guillod.
%   2020 - BSD License.

close('all')
addpath(genpath('src'))

%% solve brute force optimization
[var_param, solver_param] = get_data('bruteforce');
data_bruteforce = get_multi_obj_opt('bruteforce', var_param, solver_param);

%% solve single-objective optimization with genetic algorithm
[var_param, solver_param] = get_data('ga');
data_ga = get_multi_obj_opt('ga', var_param, solver_param);

%% solve multi-objective optimization with genetic algorithm
[var_param, solver_param] = get_data('gamultiobj');
data_gamultiobj = get_multi_obj_opt('gamultiobj', var_param, solver_param);

%% plot the results
figure()
plot3(data_bruteforce.sol.input.x_1, data_bruteforce.sol.input.x_2, data_bruteforce.sol.input.x_3, 'xb')
hold('on')
plot3(data_gamultiobj.sol.input.x_1, data_gamultiobj.sol.input.x_2, data_gamultiobj.sol.input.x_3, 'dr')
plot3(data_ga.sol.input.x_1, data_ga.sol.input.x_2, data_ga.sol.input.x_3, 'og', 'markerfacecolor', 'g')
grid('on')
xlabel('x_{1}')
ylabel('x_{2}')
zlabel('x_{3}')
legend({'bruteforce', 'gamultiobj', 'ga'}, 'Location', 'northeast')
title('Multi-Objective Optimization / Input')

figure()
plot(data_bruteforce.sol.output.y_1, data_bruteforce.sol.output.y_2, 'xb')
hold('on')
plot(data_gamultiobj.sol.output.y_1, data_gamultiobj.sol.output.y_2, 'dr')
plot(data_ga.sol.output.y_1, data_ga.sol.output.y_2, 'og', 'markerfacecolor', 'g')
grid('on')
xlabel('y_{1}')
ylabel('y_{2}')
legend({'bruteforce', 'gamultiobj', 'ga'}, 'Location', 'northeast')
title('Multi-Objective Optimization / Output')

end

