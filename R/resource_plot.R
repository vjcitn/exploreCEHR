
getnum = function (x) as.numeric(gsub("[A-Za-z% ]*", "", x))

#' example nvidia-smi trace dataset
#' @return data.frame
#' @examples
#' plot_trace(demotrace_path())
#' @export
demotrace_path = function()
  system.file("performance", "gpu_demo1_trace.csv", package="exploreCEHR")

#' visualize various aspects of performance with GPU
#' @import lubridate
#' @param pa path to an nvidia-smi trace file
#' @return plot
#' @examples
#' plot_trace(demotrace_path())
#' @export
plot_trace = function(pa) {
  opar = par(no.readonly=TRUE)
  on.exit(par(opar))
  dat = read.delim(pa, check.names=FALSE, sep=",")
  dn = names(dat)
  nc = ncol(dat)
  dat[,1] = as_datetime(dat[,1])
  for (i in seq(2,nc)) dat[,i] = getnum(dat[,i])
  par(mfrow=c(3,2), mar=c(4,5,2,2))
  tim = as_datetime(dat[,1])
  todo = c(2,3,4,5,7,8)
  for (i in todo) plot(tim, dat[,i], type="l", ylab=dn[i], xlab="clock time")
}
