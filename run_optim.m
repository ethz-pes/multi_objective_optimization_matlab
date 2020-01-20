function run_optim()

close('all')
addpath(genpath('src'))

%% optim
param = get_data('brute');
data_brute = get_optim('data', param);

param = get_data('ga');
data_ga = get_optim('data', param);

param = get_data('gamultiobj');
data_gamultiobj = get_optim('data', param);

%% plot
figure()
plot(data_brute.sol_valid.y_1, data_brute.sol_valid.y_2, 'xb')
hold('on')
plot(data_ga.sol_valid.y_1, data_ga.sol_valid.y_2, 'og')
plot(data_gamultiobj.sol_valid.y_1, data_gamultiobj.sol_valid.y_2, '+r')

end
