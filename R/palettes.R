#' Predefined palettes and palette generators
#'
#' These functions are analogs to familiar R color palettes but based on Lego
#' colors.
#'
#' @param n if not provided, return the vector of official Lego colors defining
#' the palette. If provided, return an interpolated palette, which will contain
#' non-Lego colors only if \code{n} is greater than the palette definition.
#'
#' @return character vector of hex colors
#' @export
#' @name lc_palettes
#'
#' @examples
#' lc_terrain()
#' lc_terrain(4)
#'
#' lc_topo()
#' lc_heat()
lc_terrain <- function(n){
.lc_palette(.lc_terrain, n)
}

#' @export
#' @rdname lc_palettes
lc_topo <- function(n){
  .lc_palette(.lc_topo, n)
}

#' @export
#' @rdname lc_palettes
lc_heat <- function(n){
  .lc_palette(.lc_heat, n)
}


.lc_palette <- function(x, n){
  if(missing(n)){
    x
  } else if(n <= length(x)){
    x[round(seq(1, length(x), length.out = n))]
  } else {
    grDevices::colorRampPalette(x)(n)
  }
}
