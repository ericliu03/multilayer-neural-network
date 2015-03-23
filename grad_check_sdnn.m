function average_error = grad_check(fun, theta0, num_checks, data, labels,ei)

  delta=1e-3; 
  sum_error=0;

  fprintf(' Iter       i             err');
  fprintf('           g_est               g               f\n')

  for i=1:num_checks
    T = theta0;
    j = randsample(numel(T),1);
    T0=T; T0(j) = T0(j)-delta;
    T1=T; T1(j) = T1(j)+delta;
    pred_only = false;
    [f,g] = fun(T, ei , data, labels, pred_only);
    f0 = fun(T, ei , data, labels, pred_only);
    f1 = fun(T, ei , data, labels, pred_only);

    g_est = (f1-f0) / (2*delta);
    error = abs(g(j) - g_est);

    fprintf('% 5d  % 6d % 15g % 15f % 15f % 15f\n', ...
            i,j,error,g(j),g_est,f);

    sum_error = sum_error + error;
  end

  average_error = sum_error/num_checks;
