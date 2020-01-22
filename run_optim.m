function run_optim()

close('all')
addpath(genpath('src'))

%% optim
param = get_data('bruteforce');
data_brute = get_optim('bruteforce', param);

param = get_data('ga');
data_ga = get_optim('ga', param);

param = get_data('particleswarm');
data_ps = get_optim('particleswarm ', param);

param = get_data('paretosearch');
data_paretosearch = get_optim('paretosearch ', param);

param = get_data('gamultiobj');
data_gamultiobj = get_optim('gamultiobj', param);

%% plot

fprintf('%.3f / %.3f\n', data_ga.sol.y_1, data_ga.sol.y_2)
fprintf('%.3f / %.3f\n', data_ps.sol.y_1, data_ps.sol.y_2)

figure()
plot(data_brute.sol.y_1, data_brute.sol.y_2, 'xb')
hold('on')
plot(data_gamultiobj.sol.y_1, data_gamultiobj.sol.y_2, 'dr')
plot(data_paretosearch.sol.y_1, data_paretosearch.sol.y_2, 'dg')
grid('on')
xlabel('y_{1}')
ylabel('y_{2}')

end
