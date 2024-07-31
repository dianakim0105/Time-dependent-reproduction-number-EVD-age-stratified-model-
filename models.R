#One-host model set-up for estimating R_t

one_host_model <- function(cases,w,tau){
  a<-c() #shape parameter
  p<-c() #infection potential
  b<-c()#scale parameter
  alpha <- 1 #shape hyperparamter 
  beta <- 5 #scale hyperparameter
  for (i in 1:(n_days-1)){
    p[1] <- NaN
    p[i+1] <- sum(cases[i:1]*w[1:i]) #total infectivity potential on day t starting from day t=2
  }
  p<-p
  for (j in 2:(n_days-tau)){
    a[j-1] <- alpha+sum(cases[j:(j+tau)])
    b[j-1] <- 1/(sum(p[j:(j+tau)])+1/beta) 
  }
  return(data.frame(shape=a,scale=b,R_mean=a*b))
}

#Two-host model set-up for estimating R_t

two_host_model <- function(I1,I2,cases,C_eff,w_children,w_adults,tau){
  a <- c() #shape parameter
  b <- c() #scale parameter
  alpha <- 1 #shape hyperparameter
  beta <- 5 #scale hyperparamter 
  eta <- c()
  for (i in 1:(n_days-1)){
    eta[1] <- NaN
    eta[i+1] <- ((C_eff[1,1]+C_eff[1,2])*sum(I1[i:1]*w_children[1:i])+(C_eff[2,2]+C_eff[2,1])*sum(I2[i:1]*w_adults[1:i]))/lambda ##total infectivity potential on day t starting from day t=2
                                                                                
  }
  eta <- eta
  for (j in 2:(n_days-tau)){
    a[j-1] <- alpha+sum(cases[j:(j+tau)])
    b[j-1] <- 1/(sum(eta[j:(j+tau)])+1/beta)
  }
  
  return(data.frame(shape=a,scale=b,R_mean=a*b))
  
}


