function run_optim()

close('all')
addpath(genpath('src'))

%% optim
param = get_data('bruteforce');
data_brute = get_optim('bruteforce', param);

param = get_data('ga');
data_ga = get_optim('ga', param);

param = get_data('gamultiobj');
data_gamultiobj = get_optim('gamultiobj', param);

%% plot
figure()
plot(data_brute.sol.struct.y_1, data_brute.sol.struct.y_2, 'xb')
hold('on')
plot(data_gamultiobj.sol.struct.y_1, data_gamultiobj.sol.struct.y_2, 'dr')
plot(data_ga.sol.struct.y_1, data_ga.sol.struct.y_2, 'og')
grid('on')
xlabel('y_{1}')
ylabel('y_{2}')

end

