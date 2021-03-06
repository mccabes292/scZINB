#' Neighborhood selection for zero-inflated negative binomial regression
#'
#' Estimate the moral graph using the penalized ZINB regression based on the 
#' zero-inflated count sample data
#' 
#'
#' @param dat the zero-inflated count sample data with n observations and p 
#' variables
#' @param filter a binary matrix indicating the initial filter prior to the 
#' variable selection in ZINB regression. Default is \code{NULL}, which uses
#' all the covariates. 
#' @param bic the criterion used to create the graph, could be "BIC", "extBIC"
#' or "extBICGG". Default is "extBIC".  
#' @param unpenalizedx,unpenalizedz Additional unpenalized covariates for 
#' negative binomial and logistic regression respectively. Default is 
#' \code{NULL}.
#' @param lambdas,taus specific tuning parameter values you want to run the 
#' model with. Default is \code{NULL} where the function will auto-generate
#' a tuning parameter search grid. If default is used, must have input for
#' nlambda and ntau.
#' @param nlambda,ntau number of unique lambda and tau values - default are 30 
#' and 5.
#' @param naPercent allowable percentage of observations with missing values - 
#' default is .4.
#' @param warmStart default is 'cond', which resets the starting point to 
#' the original starting point when non-convergence happens. Other options are 
#' TRUE, which keeps previous estimates as starting points for estimation for 
#' the next tuning parameter; FALSE uses the same starting point for all tp.
#' @param bicgamma the parameter used in the extended BIC. Default is \code{NULL}, 
#' which uses the log(the dimension)/log(the sample size). 
#' @param maxOptimIT maximum number of iterations for numerical optimization 
#' (BFGS) after the EM algorithm. By default is set to 50. Convergence time
#' is long. 
#' @param eps threshold for convergence for the EM algorithm - default is 1e-5.
#' @param start default is 'jumpstart', which estimates the starting coefficients
#' from penalized negative binomial estimation and logistic regression based on
#' the penalized library. If set to \code{NULL}, then set starting coefficients 
#' values to 0. Otherwise, can also take direct input for starting
#' values. Must be in the form of list(betas = v1, gammas = v2), where v1 and
#' v2 are vectors the length of the number of covariates in X.
#' @param controlDat Data to control for in the model. Log transformation to be applied . If NULL then `dat` is used as default.
#' 
#' @return returns the estimated moral graph.
#' @seealso \code{\link{penZINB}} for the penalized zero-inflated negative 
#' binomial model.
#' @export
nsZINB <- function(dat, controlDat=NULL, filter = NULL, bic = "extBIC", 
                   unpenalizedx = NULL, unpenalizedz = NULL, 
                   lambdas = NULL, taus = NULL, nlambda = 30, ntau = 5, 
                   naPercent = .4, warmStart = "cond", bicgamma = NULL,
                   maxOptimIT = 0, theta.st = NULL, oneTheta = FALSE,
                   eps = 1e-5, start = "jumpstart"){
  
  
  p <- ncol(dat)
  
  if(is.null(controlDat)){
    controlDat=dat
  }
  
  if(is.null(filter)){
    filter <- matrix(1, p, p)
    diag(filter) <- 0
  }
  
  res1 <- lapply(1:ncol(dat), function(i){
    y <- dat[, i]
    X <- controlDat[, which(filter[, i] != 0), drop = FALSE]
    tmp <- penZINB(y, log(X + 1/6), maxIT = 100, 
                   maxOptimIT = maxOptimIT, 
                   theta.st = theta.st, oneTheta = oneTheta,
                   unpenalizedx = unpenalizedx, unpenalizedz = unpenalizedz,
                   lambdas = lambdas, taus = taus, nlambda = nlambda, ntau = ntau, 
                   naPercent = naPercent, warmStart = warmStart, 
                   bicgamma = bicgamma, start = start, 
                   eps = eps)
    tmp
  })
  
  gh1 <- createGraph(res1, filter = filter, bic = bic)
  mgh1 <- mirror(gh1)
  return(mgh1)
  
}

