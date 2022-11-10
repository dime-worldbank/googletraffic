if(F){
  setwd("~/Documents/Github/googletraffic")
  
  roxygen2::roxygenise("~/Documents/Github/googletraffic")
  
  pkgdown::deploy_to_branch()
  usethis::use_github_action_check_standard()
  
  ## Comand line code for building and checking package
  #R CMD build --as-cran "~/Documents/Github/googletraffic"
  #R CMD check --as-cran "~/Documents/Github/googletraffic/googletraffic_0.0.0.9000.tar.gz"
  
  devtools::check("~/Documents/Github/googletraffic")
  
  devtools::check_win_devel("~/Documents/Github/googletraffic")
  devtools::check_win_release("~/Documents/Github/googletraffic")
  devtools::check_win_oldrelease("~/Documents/Github/googletraffic")
  
  devtools::build("~/Documents/Github/googletraffic")
}