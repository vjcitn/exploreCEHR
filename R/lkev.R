#' path to events data
#' @export
events_path = function()
  system.file("inputs", "events.parquet", package="exploreCEHR")

#' browser for events data
#' @import DT
#' @param nrec numeric defaults to 5000
#' @export
browse_events = function(nrec=5000) {
  evdf = arrow::read_parquet(events_path()) |> head(nrec)
  DT::datatable(evdf)
}
