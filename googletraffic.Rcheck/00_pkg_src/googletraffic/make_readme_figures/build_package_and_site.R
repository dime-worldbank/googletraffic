if(F){
  roxygen2::roxygenise("~/Documents/Github/googletraffic")
  
  setwd("~/Documents/Github/googletraffic")
  pkgdown::deploy_to_branch()
  
  #R CMD build --as-cran "~/Documents/Github/googletraffic"
  #R CMD check --as-cran "~/Documents/Github/googletraffic"
}