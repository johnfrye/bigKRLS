% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/bigKRLS.R
\docType{package}
\name{bigKRLS}
\alias{bigKRLS}
\alias{bigKRLS-package}
\alias{bigKRLS-package}
\alias{bigKRLS}
\title{bigKRLS}
\usage{
bigKRLS(y = NULL, X = NULL, sigma = NULL, derivative = TRUE,
  which.derivatives = NULL, vcov.est = TRUE, lambda = NULL, L = NULL,
  U = NULL, tol = NULL, model_subfolder_name = NULL,
  overwrite.existing = FALSE, Ncores = NULL, acf = FALSE, noisy = NULL,
  instructions = TRUE)
}
\arguments{
\item{y}{A vector of numeric observations on the dependent variable; missing values not allowed. May be base R matrix or library(bigmemory) big.matrix.}

\item{X}{A matrix of numeric observations of the independent variables; factors, missing values, and constant vectors not allowed. May be base R matrix or library(bigmemory) big.matrix.}

\item{sigma}{Bandwidth parameter, shorthand for sigma squared. Default: sigma <- ncol(X). Since x variables are standardized, facilitates interprepation of the Gaussian kernel, exp(-dist(X)^2/sigma) a.k.a the similarity score. Of course, if dist between observation i and j is 0, there similarity is 1 since exp(0) = 1. Suppose i and j differ by one standard deviation on each dimension. Then the similarity is exp(-ncol(X)/sigma) = exp(-1) = 0.368.}

\item{derivative}{Logical: Estimate derivatives (as opposed to just coefficients)? Recommended for interpretability.}

\item{which.derivatives}{Optional. For which columns of X should marginal effects be estimated ("variables of interest"). If derivative=TRUE and which.derivative=NULL, all will marginal effects estimated (default settings). Example: out = bigKRLS(..., which.derivatives = c(1, 3, 5))}

\item{vcov.est}{Logical: Estimate variance covariance matrix? Required to obtain derivatives and standard errors on predictions (default = TRUE).}

\item{lambda}{Regularization parameter. Default: estimated based (in part) on the eigenvalues of the kernel via Golden Search with convergence parameter "tolerance." Must be positive, real number.}

\item{L}{Lower bound of Golden Search for lambda.}

\item{U}{Upper bound of Golden Search for lambda.}

\item{tol}{tolerance parameter for Golden Search for lambda. Default: N / 1000.}

\item{model_subfolder_name}{If not null, will save estimates to this subfolder of your current working directory. Alternatively, use save.bigKRLS() on the outputted object.}

\item{overwrite.existing}{Logical: overwrite contents in folder 'model_subfolder_name'? If FALSE, appends lowest possible number to model_subfolder_name name (e.g., ../myresults3/).}

\item{Ncores}{Number of processor cores to use. Default = ncol(X) or N - 2 (whichever is smaller). More than N - 2 NOT recommended. Uses library(parallel) unless Ncores = 1.}

\item{acf}{Logical. Experimental; default == FALSE. Calculate Neffective as function of mean absolute auto-correlation in X to correct p-values? Requires ncol(X) > 2. Intended for data that may violate i.i.d. To correct P values with this effective sample size, call summary(out, pval_type = "acf").}

\item{noisy}{Logical: Display detailed version of progress to console (intermediate output, time stamps, etc.) as opposed to minimal display? Default: if(N > 2000) TRUE else FALSE. SSH users should use X11 forwarding to see Rcpp progress display.}

\item{instructions}{Display syntax after estimation with other library(bigKRLS) functions that can be used on output? Logical. (This parameter is different from noisy for the sake of crossvalidation.bigKRLS().)}
}
\value{
bigKRLS Object containing slope and uncertainty estimates; summary() and predict() defined for class bigKRLS, as is shiny.bigKRLS().
}
\description{
Runtime and Memory Optimized Kernel Regularized Least Squares
Pete Mohanty (Stanford University) and Robert Shaffer (University of Texas at Austin)

bigKRLS
}
\details{
Kernel Regularized Least Squares (KRLS) is a kernel-based, complexity-penalized method developed by Hainmueller and Hazlett (2014) to minimize parametric assumptions while maintaining interpretive clarity. Here, we introduce bigKRLS, an updated version of the original KRLS R package with algorithmic and implementation improvements designed to optimize speed and memory usage. These improvements allow users to straightforwardly fit KRLS models to medium and large datasets (N > ~2500).

Major Updates

1. C++ integration. We re-implement most major computations in the model in C++ via Rcpp and RcppArmadillo. These changes produce up to a 50\% runtime decrease compared to the original R implementation even on a single core.

2. Leaner algorithm. Because of the Tikhonov regularization and parameter tuning strategies used in KRLS, the method of estimation is inherently memory-heavy O(N^2), making memory savings important even in small- and medium-sized applications. We develop and implement a new local derivatives algorithm, which reduces peak memory usage by approximately an order of magnitude, and cut the number of computations needed to find regularization parameter in half.

3. Improved memory management. Most data objects in R perform poorly in memory-intensive applications. We use a series of packages in the bigmemory environment to ease this constraint, allowing our implementation to handle larger datasets more smoothly.

4. Parallel Processing. Parallel processing with parallel makes the algorithm much faster for the marginal effects.

5. Interactive data visualization. We've designed an R Shiny app that allows users bigKRLS users to easily share results with collaborators or more general audiences. Simply call shiny.bigKRLS() on the outputted regression object.

6. Honest p values. bigKRLS now computes p values that reflect both the regularization process and the number of predictors. For details and other options, see help(summary.bigKRLS).

7. Cross-validation, including K folds crossvalidation. crossvalidate.bigKRLS performs CV, stores a number of in and out of sample statistics, as well as metadata documenting how the were split, the bigmemory file structure (if appropriate), and so on. See vignette("bigKRLS_basics") or help("crossvalidate.bigKRLS") for syntax.

Requirements. bigKRLS is under active development. bigKRLS, as well its dependencies, require current versions of R and its compilers (and RStudio if used). For details, see \url{https://github.com/rdrr1990/code/blob/master/bigKRLS_installation.md}.

For details on syntax, load the library and then open our vignette vignette("bigKRLS_basics"). Because of the quadratic memory requirement, users working on a typical laptop (8-16 gigabytes of RAM) may wish to start at N = 2,500 or 5,000, particularly if the number of *x* variables is large. When you have a sense of how bigKRLS runs on your system, you may wish to only estimate a subset of the marginal effects at N = 10-15,000 by setting bigKRLS(... which.derivatives = c(1, 3, 5)) for the marginal effects of the first, third, and fifth x variable.

Mohanty, Pete and Robert B. Shaffer. 2016. "Messy Data, Robust Inference? Navigating Obstacles to Inference with bigKRLS" Project Presented to the International Methods Colloquium and useR! 2016. Visit \url{https://sites.google.com/site/petemohanty} for most recent version.

Hainmueller, Jens and Chad Hazlett. 2014. "Kernel Regularized Least Squares: Reducing Misspecification Bias with a Flexible and Interpretable Machine Learning Approach." Political Analysis. 22:143-68. \url{https://web.stanford.edu/~jhain/Paper/PA2014a.pdf} (Accessed May 20th, 2016).

Recent papers, presentations, and other code available at \url{github.com/rdrr1990/code/}

License 
Code released under GPL (>= 2).
}
\examples{
# weight of chickens toy dataset
# y <- as.matrix(ChickWeight$weight) 
# X <- matrix(cbind(ChickWeight$Time, ChickWeight$Diet == 1), ncol = 2)
# out <- bigKRLS(y, X)
# out$R2                                     # 0.7635361
# summary(out, labs = c("Time", "Diet")) 
# save.bigKRLS(out, "exciting_results") 
# don't use save() unless out$has.big.matrices == FALSE
# out2 <- bigKRLS(y, X, which.derivatives = 2) 
# if x2 is variable of interest 
}
\seealso{
Useful links:
\itemize{
  \item \url{https://github.com/rdrr1990/bigKRLS}
  \item Report bugs at \url{https://github.com/rdrr1990/bigKRLS/issues}
}

}
\author{
\strong{Maintainer}: Pete Mohanty \email{pete.mohanty@gmail.com}

Authors:
\itemize{
  \item Robert Shaffer \email{rbshaffer@utexas.edu}
}

}
