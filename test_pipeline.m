clear; clc;

eps = 1e-8;
Nplot = 1000;
eps_rel = 1e-15;

% Neural-net style test functions
tests(1).f    = @(x) max(x, 0);                      
tests(1).name = 'ReLU';

tests(2).f    = @(x) 0.5*x.*(1 + erf(x / sqrt(2)));    
tests(2).name = 'GELU-ish';

tests(3).f    = @(x) exp(x);
tests(3).name = 'exp(x)';

tests(4).f    = @(x) sin(x);
tests(4).name = 'sin(x)';

tests(5).f    = @(x) tanh(x);
tests(5).name = 'tanh(x)';

tests(6).f    = @(x) 1./(1 + exp(-x));                
tests(6).name = 'sigmoid';

tests(7).f    = @(x) log(1 + exp(x));                  
tests(7).name = 'softplus';

tests(8).f    = @(x) x ./ (1 + exp(-x));             
tests(8).name = 'swish';

doms = {[-5, 5], [-10, 10]};

for ti = 1:numel(tests)
    f    = tests(ti).f;
    name = tests(ti).name;

 
    err_abs   = cell(1,2);
    err_rel   = cell(1,2);
    xs_all    = cell(1,2);

    fprintf('\n======\n');
    fprintf('Function: %s\n', name);

    for di = 1:2
        dom = doms{di};
        fprintf('  Domain [%g, %g]\n', dom(1), dom(2));

        p_best = Fapprox(dom, f, eps);
        theta  = Rb_transform(p_best);
        B = numel(theta);
        fprintf('    B = %d\n', B);

        % Sample points
        xs_double = linspace(dom(1), dom(2), Nplot);
        xs_single = single(xs_double);

        y_true  = f(xs_double);
        y_pbest = p_best(xs_double);
        y_final_single = arrayfun(@(x) Feval(theta, x), xs_single);
        y_final = double(y_final_single);

        % Errors
        abs_err_pbest = abs(y_pbest - y_true);
        abs_err_final = abs(y_final - y_true);

        err_abs{di} = abs_err_final;

        rel_err_final = abs_err_final ./ (abs(y_true) + eps_rel);
        err_rel{di} = rel_err_final;

        xs_all{di} = xs_double;
    end

    figName = sprintf('%s: Error on [-5,5] and [-10,10]', name);
    figure('Name', figName, 'NumberTitle', 'off');

    % Absolute on [-5,5]
    subplot(2,2,1);
    plot(xs_all{1}, err_abs{1}, 'b-', 'LineWidth', 1.0);
    grid on; title([name ': abs error on [-5,5]']);
    xlabel('x'); ylabel('abs error');

    % Absolute on [-10,10]
    subplot(2,2,2);
    plot(xs_all{2}, err_abs{2}, 'b-', 'LineWidth', 1.0);
    grid on; title([name ': abs error on [-10,10]']);
    xlabel('x'); ylabel('abs error');

    % Relative on [-5,5]
    subplot(2,2,3);
    plot(xs_all{1}, err_rel{1}, 'r-', 'LineWidth', 1.0);
    grid on; title([name ': rel error on [-5,5]']);
    xlabel('x'); ylabel('rel error');

    % Relative on [-10,10]
    subplot(2,2,4);
    plot(xs_all{2}, err_rel{2}, 'r-', 'LineWidth', 1.0);
    grid on; title([name ': rel error on [-10,10]']);
    xlabel('x'); ylabel('rel error');
end
