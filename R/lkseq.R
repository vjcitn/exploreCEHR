
#' path to event-sequence data
#' @export
sequences_path = function()
  system.file("inputs", "sequences.parquet", package="exploreCEHR")

process_sqdf = function(dat) {
 seqs = dat$sequence
 ss = strsplit(seqs, " \\[VS\\] ")
 ss = lapply(ss, function(x) {c(x[1], paste0("[VS] ", x[-1]))})
 ss
}

#' viewer for event-sequence data
#' @import DT
#' @param nrec numeric defaults to 5
#' @examples
#' tt = view_sequences()
#' strsplit(tt[[1]][[2]], " ")
#' @export
view_sequences = function(nrec=5) {
  sqdf = arrow::read_parquet(sequences_path()) |> head(nrec)
  process_sqdf(sqdf)
}
