if(F){
  roxygen2::roxygenise("~/Documents/Github/googletraffic")
  
  setwd("~/Documents/Github/googletraffic")
  pkgdown::deploy_to_branch()
  
  ## Comand line code for building and checking package
  #R CMD build --as-cran "~/Documents/Github/googletraffic"
  #R CMD check --as-cran "~/Documents/Github/googletraffic/googletraffic_0.0.0.9000.tar.gz"
}