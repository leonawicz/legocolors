#' Color mapping
#'
#' Map between hex and color names.
#'
#' These functions map between hex color codes and color names. Convert any color palette to a palette of the most closely matched official Lego colors.
#'
#' The two complimentary Lego color mapping functions are `hex_to_legocolors` and `legocolors_to_hex`.
#' The first takes a hex color string and converts to the nearest valid Lego color name by Euclidean distance.
#' The second takes a valid Lego color name and converts to hex.
#'
#' Valid Lego color names are determined by the definition, `def`. The four options provide different name sets for existing Lego colors.
#' The default is `def = "bricklink"`. [BrickLink](https://www.bricklink.com) is the default naming convention source for several reasons:
#'
#' * It is the most comprehensive and widely used.
#' * In terms of obtaining Lego parts online:
#'     * BrickLink serves more countries worldwide than The Lego Group's (TLG) Pick-A-Brick service.
#'     * BrickLink offers far more variety, quantity and custom order filling than Pick-A-Brick.
#'     * Pick-A-Brick has far higher prices and a vastly smaller selection of items and colors.
#' * The Adult Fans of Lego (AFOL) community is centered around BrickLink and members, buyers and sellers alike, are well versed in BrickLink Lego color naming conventions. Few are as familiar with official Lego color names.
#' * Lego color naming conventions established by other entities, including the official Lego color names known to the public, are less complete.
#' * There is also the BrickOwl website for custom part ordering, which uses official TLG color names, but is much smaller than BrickLink and tends to have significantly higher prices.
#'
#' Essentially, when converting an image or 3D model in R into a set of Lego parts that must be custom ordered to construct your design,
#' BrickLink is the clear best option for obtaining the most complete set of parts required and at the lowest price.
#'
#' If `approx = FALSE`, an unmatched element returns `NA`.
#'
#' `hex_to_color` is provided for general convenience. It converts hex color codes to the familiar R color names.
#' Consistent with the Lego-specific mapping functions, by default `approx = TRUE` returns the nearest color name based on Euclidean distance.
#' `prefix` allows for prepending an identifier to the beginning of any color name that a hex color code does not match exactly.
#'
#' @param x character, hex color or color name. May be a vector. See details.
#' @param def character, the Lego color name definition to apply: `"bricklink"`, `"ldraw"`, `"tlg"` or `"peeron"`. See details.
#' @param approx logical, find and return closest color name when an exact match does not exist.
#' @param prefix character, prefix for approximate color matches.
#' @param material logical, consider only the subset of Lego color names by filtering on levels of `legocolors$material`. By default, all are considered.
#' @param retired logical, filter out Lego colors that are retired, defaults to `FALSE`.
#'
#' @return character vector of color names or hex colors
#' @export
#' @name legocolor
#'
#' @examples
#' hex_to_color(c("#ff0000", "#ff0001"))
#' hex_to_legocolor("#ff0000")
#' hex_to_legocolor("#ff0000", material = "solid")
#' legocolor_to_hex("Red")
#' hex_to_color(legocolor_to_hex("Red"))
hex_to_color <- function(x, approx = TRUE, prefix = "~"){
  m <- grDevices::col2rgb(x)
  col_map <- data.frame(name = grDevices::colours(), t(grDevices::col2rgb(grDevices::colours())))
  d <- data.frame(name = x, red = m["red", ], green = m["green", ], blue = m["blue", ])
  d <- rbind(d, col_map)
  m <- as.matrix(d[, -1])
  rownames(m) <- d[, 1]
  .f <- function(i){
    id <- names(which.min(as.matrix(stats::dist(m, upper = TRUE))[i,][-c(1:i)]))
    hex2 <- do.call(grDevices::rgb, c(as.list(grDevices::col2rgb(id)), maxColorValue = 255))
    if(hex2 == toupper(x[i])) id else if(approx) paste0(prefix, id) else as.character(NA)
  }
  sapply(seq_along(x), .f)
}

#' @export
#' @rdname legocolor
hex_to_legocolor <- function(x, def = c("bricklink", "ldraw", "tlg", "peeron"),
                             approx = TRUE, prefix = "~", material = NULL, retired = FALSE){
  lc <- legocolors::legocolors
  def <- match.arg(def)
  def <- switch(def, bricklink = "bl_name", ldraw = "ldraw_name", tlg = "lego_name", peeron = "peeron_name")
  col_map <- data.frame(name = lc[[def]], t(grDevices::col2rgb(lc$hex)), hex = lc$hex,
                        material = lc$material, year_retired = lc$year_retired, stringsAsFactors = FALSE)
  col_map$name[is.na(col_map$name)] <- "Unnamed"
  if(!is.null(material)){
    if(any(!material %in% levels(lc$material)))
      stop("Invalid material. See `legocolors`.")
    col_map <- col_map[col_map$material %in% material, ]
  }
  if(!retired) col_map <- col_map[is.na(col_map$year_retired), ]
  hex_vec <- col_map$hex
  col_map$material <- col_map$year_retired <- col_map$hex <- NULL

  m <- grDevices::col2rgb(x)
  d <- data.frame(name = x, red = m["red", ], green = m["green", ], blue = m["blue", ])
  d <- rbind(d, col_map)
  m <- as.matrix(d[, -1])
  rownames(m) <- d[, 1]
  .f <- function(i){
    id <- names(which.min(as.matrix(stats::dist(m, upper = TRUE))[i, ][-c(seq_along(x))]))
    hex2 <- hex_vec[col_map$name == id]
    if(hex2[1] == toupper(x[i])) id else if(approx) paste0(prefix, id) else as.character(NA)
  }
  sapply(seq_along(x), .f)
}

#' @export
#' @rdname legocolor
legocolor_to_hex <- function(x, def = c("bricklink", "ldraw", "tlg", "peeron")){
  def <- match.arg(def)
  def <- switch(def, bricklink = "bl_name", ldraw = "ldraw_name", tlg = "lego_name", peeron = "peeron_name")
  lc <- legocolors::legocolors
  idx <- match(x, lc[[def]])
  lc$hex[idx]
}
