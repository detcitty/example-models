data {
  int N;
  vector[N] y;
  int J;
  array[N] int<lower=1, upper=J> movie;
}
parameters {
  vector<lower=0, upper=5>[J] theta;
  real<lower=0, upper=2.5> sigma_y;
}
model {
  theta ~ normal(3, 1);
  y ~ normal(theta[movie], sigma_y);
}
