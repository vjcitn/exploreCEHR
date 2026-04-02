#' path to notations table
#' @export
notation_path = function()
  system.file("notations", "token_lookup.csv", package="exploreCEHR")

#' browser for notations data
#' @export
browse_notation = function() {
  read.csv(notation_path()) |> DT::datatable()
}
