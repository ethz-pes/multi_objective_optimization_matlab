function run_optim()

close('all')
addpath(genpath('src'))

%% optim
param = get_data('bruteforce');
data_brute = get_optim('bruteforce', param);

% param = get_data('patternsearch');
% data_ps = get_optim('patternsearch', param);

param = get_data('fmincon');
data_ps = get_optim('fmincon', param);

% param = get_data('ga');
% data_ga = get_optim('ga', param);
% 
% param = get_data('gamultiobj');
% data_gamultiobj = get_optim('gamultiobj', param);

%% plot
figure()
plot(data_brute.sol.y_1, data_brute.sol.y_2, 'xb')
hold('on')
plot(data_ps.sol.y_1, data_ps.sol.y_2, 'og')



% plot(data_ga.sol.y_1, data_ga.sol.y_2, 'og')
% plot(data_gamultiobj.sol.y_1, data_gamultiobj.sol.y_2, '+r')
% grid('on')
% legend('brute force', 'genetic single obj', 'genetic multi obj')
% xlabel('y_{1}')
% ylabel('y_{2}')

end
