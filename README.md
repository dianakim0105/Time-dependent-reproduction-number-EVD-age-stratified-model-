The score-based pipeline (VE + Langevin) implemented for a single bivariate correlated Gaussian distribution N(mu, Sigma+sigma_max^2*I) and a mixture of 2D Gaussians splits into two components:

1. Score learning 

2. Sampling

We started from comparing learned score field vs true score field. A linear score network was expressive enough for a single Gaussian as the true noisy score is linear.The score diagnostics indicated that the model was learning the score reasonably well. 
For the sampling phase we used a standard NCSN-style annealed Langevin step-size rule with extra refinement at the smallest sigma, and an optional final denoising step. The sampling was carried out with the learned score and the exact true score. We then explored the sample plots for the minimum noise level in the schedule. For both the learned score and the exact true Gaussian score the final samples were too dispersed and the samples covariance was inflated. This confirmed that the main issue is not score learning. Because we know that the sampler stops at sigma_min > 0 rather than at sigma=0 we compared the samples against the noisy marginal distribution p_sigma_min(x) rather than the clean target N(mu, Sigma) only. The mismatch persisted.
The next step was to look at initialization. Initially we had the sampler initialize at N(0,sigma_max^2*I) while the true forward endpoint for a Gaussian dataset is N(mu, Sigma-sigma_max^2*I). After having corrected the initialization the covariance was still substantially off. Another potential source of mismatch could be annealing across sigmas that amplifies the baseline bias from discretized Langevin itself. Having removed annealing and ran Langevin at a single fixed sigma=0.1 using the exact score, there was still some covariance inflation bit it was less severe compared with the annealed case. This confirmed that annealing indeed makes the bias worse. 

In general, samplers are split into predictors and correctors. A predictor is any numerical solver for the reverse-time SDE, which moves from one noise level to the next. A corrector is a score-based MCMC step, such as Langevin, applied at the current noise level to better match the local marginal p_t. A predcitor-corrector (PC) sampler alternates the two at every step.The predictor handles the global reverse evolution, while the corrector repairs local discretization error and better aligns the sample with the current noisy marginal. Corrector-only tends to be the weakest sampling approach for a fixed computer budget (Song et al.,2021)  

After introducing a predictor step based on Euler-Maruyama discretization of the reverse SDE and keeping the corrector as Langevin with fixed initialisation described above, the final samples matched the target noisy marginal much more closely:

- the mean error is small
- covariance is no longer inflated 
- the sample cloud visually matches the noisy marginal

Having implemented the VE/DSM pipeline for a more complex target (the true distribution is a mixture of 2D Gaussians) managed to show that the linear architecture is inadequate for multimodal distributions since the true score field is now nonlinear. The linear model fails to recover this multimodal nonlinear structure. This is motivation to move to a nonlinear neural network architecture. 

Introducing a nonlinear MLP (a simple neural network with a few layers and neurons that can learn nonlinear functions) substantially improved recovery of the multimodal score field. The sampling approach was the same as for the single Gaussian setup and a similar result was achieved. 
