# bigKRLS is authored by Pete Mohanty and Robert Shaffer

# the below RStudio version control code is adapted from Dirk Eddelbuettel's library(anytime) 
# and https://github.com/eddelbuettel/anytime/blob/ef8b1e52b80a99e96f46232dfe29180686327887/R/init.R#L49-L52
# in light of this helpful discussion: 
# http://stackoverflow.com/questions/43247649/rcpparmadillo-bigmemory-crashes-windows-rstudio-but-no-other-gui-os-type
# mistakes are of course ours 

# bigKRLS requires R 3.3.0 or newer, which is taken care of by the package description
# the code below enables an analogous check on RStudio version


RStudio_outdated <- function(){
  .pkgenv$RStudio_outofdate
}

check_platform <- function(){
  
  problem <- RStudio_outdated()
  if(is.null(problem)){
    problem <- if(.Platform$GUI == "RStudio"){
      threshold <- if(.Platform$OS.type == "unix") "1.0.136" else "1.1.129"
      !(Sys.getenv("RSTUDIO", unset="0") == "1" &&
          exists("RStudio.Version") &&
          eval(parse(text=paste0("RStudio.Version()$version ",  " >= ", "\"", threshold, "\""))))
    } else FALSE
  }
  
  if(problem){
    if(.Platform$OS.type == "unix"){
      stop("\n\nFor your operating system (OSX or Unix), bigKRLS requires RStudio 1.0.136 or higher. To use bigKRLS, switch to RGui or download the current RStudio from:\n\n      https://www.rstudio.com/products/rstudio/download/ \n\n") 
    }else{
      stop("\n\nFor your operating system (Windows), bigKRLS requires RStudio 1.1.129 or higher. To use bigKRLS, switch to RGui or download the current RStudio from:\n \n      https://www.rstudio.com/products/rstudio/download/ \n\n")  
    }  
  }
}
