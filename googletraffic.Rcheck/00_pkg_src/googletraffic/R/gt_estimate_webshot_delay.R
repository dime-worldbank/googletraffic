# Webshot Delay

# If not specified, estimate `webshot_delay` using height and width
# 
# @param height Height
# @param width Width
# @param webshot_delay Webshot Delay
# 
# @return webshot_delay (in seconds).
gt_estimate_webshot_delay <- function(height, 
                                      width, 
                                      webshot_delay){
  
  if(is.null(webshot_delay)){
    hw_max <- max(height, width)
    webshot_delay <- max(1,hw_max / 200)
  }
  
  return(webshot_delay)
}