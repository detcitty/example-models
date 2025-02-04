functions {
  real quantile_user_defined(vector x, real p) {
    int n; // length of vector x
    real index; // integer index of p
    int lo; // lower integer cap of the index
    int hi; // higher integer cap of the index
    real h; // generated weight between the lo and hi
    real qs; // weighted average of x[lo] and x[hi]
    n = num_elements(x);
    index = 1 + (n - 1) * p;
    lo = 1;
    while ((lo + 1) < index) {
      lo = lo + 1;
    }
    hi = lo + 1;
    h = index - lo;
    qs = (1 - h) * sort_asc(x)[lo] + h * sort_asc(x)[hi];
    return qs;
  }
}
data {
  int<lower=0> N; // sample size
  vector[N] y; // observed outcome
  vector[N] w; // treatment assigned
}
parameters {
  real alpha; // intercept
  real tau; // super-population average treatment effect
  real<lower=0> sigma; // pooled residual SD for the control and the treated 
}
model {
  // PRIORS
  alpha ~ normal(0, 100);
  tau ~ normal(0, 100);
  sigma ~ normal(0, 100);
  // sigma ~ inv_gamma(1, 0.01);  
  
  // LIKELIHOOD
  y ~ normal(alpha + tau * w, sigma);
}
generated quantities {
  real tau_fs; // finite-sample average treatment effect
  real tau_qte25; // quantile treatment effect at p = 0.25
  real tau_qte50; // quantile treatment effect at p = 0.50
  real tau_qte75; // quantile treatment effect at p = 0.75
  array[N] real y0; // potential outcome if W = 0
  array[N] real y1; // potential outcome if W = 1
  array[N] real tau_unit; // unit-level treatment effect
  for (n in 1 : N) {
    real mu_c = alpha;
    real mu_t = alpha + tau;
    if (w[n] == 1) {
      y0[n] = mu_c + (y[n] - mu_t);
      y1[n] = y[n];
    } else {
      y0[n] = y[n];
      y1[n] = mu_t + (y[n] - mu_c);
    }
    tau_unit[n] = y1[n] - y0[n];
  }
  tau_fs = mean(tau_unit);
  tau_qte25 = quantile_user_defined(to_vector(y1), 0.25)
              - quantile_user_defined(to_vector(y0), 0.25);
  tau_qte50 = quantile_user_defined(to_vector(y1), 0.50)
              - quantile_user_defined(to_vector(y0), 0.50);
  tau_qte75 = quantile_user_defined(to_vector(y1), 0.75)
              - quantile_user_defined(to_vector(y0), 0.75);
}
