library(dplyr)
url <- "http://www.ryanhowerter.net/colors"
x <- xml2::read_html(url)
d <- x %>% rvest::html_nodes("table") %>% rvest::html_table() %>% `[[`(1)
names(d) <- tolower(gsub("'s|\\.", "", gsub("(.*)_\\(.*", "\\1", gsub(" ", "_", names(d)))))
idx <- grep("year", names(d))
names(d)[idx] <- c("year_released", "year_retired")
d[d == ""] <- NA
d <- mutate_if(d, is.character, function(x) gsub("\\*", "", x))
d0 <- slice(d, 203)
d[203, c(6, 7, 10)] <- c("111", "Speckle Black-Silver", "BlackGlitter")
d0[1, c(6, 7, 10)] <- c("117", "Speckle DBGray-Silver", "DkStoneGlitter")
d <- bind_rows(d, d0)
d <- filter(d, !(material == "Metallic" & bl_id == 70))
idx <- which(d$material == "Pearl" & grepl("Metallic Green", d$bl_name))
d[idx, c(1, 9)] <- c("Metallic", "MetallicGreen")
d[idx, 8] <- 81L

missing_colors <- c(Rust = "#B52C20", `Light Pink` = "#FFE1FF", `Chrome Antique Brass` = "#645A4C", `Chrome Black` = "#544E4F", `Chrome Blue` = "#5C66A4",
                    `Chrome Green` = "#3CB371", `Chrome Pink` = "#AA4D8E", `Metallic Gold` = "#B8860B", `Metallic Green` = "#BDB573",
                    `Glitter Trans-Light Blue` = "#68BCC5", `Glitter Trans-Neon Green` = "#C0F500", `Speckle Black-Silver` = "#7C7E7C",
                    `Speckle DBGray-Silver` = "#4A6363", `Speckle Black-Copper` = "#5F4E47", `Speckle Black-Gold` = "#AB9421", `Mx Clear` = "#FFFFFF",
                    `Mx White` = "#FFFFFF", `Mx Light Gray` = "#9C9C9C", `Mx Black` = "#000000", `Mx Terracotta` = "#5C5030", `Mx Buff` = "#DEC69C",
                    `Mx Ochre Yellow` = "#FED557", `Mx Olive Green` = "#7C9051", `Mx Teal Blue` = "#467083", `Mx Brown` = "#907450",
                    `Mx Pastel Blue` = "#68AECE", `Mx Orange` = "#F47B30", `Mx Red` = "#B52C20", `Mx Pastel Green` = "#7DB538", `Mx Lemon` = "#BDC618",
                    `Mx Pink` = "#F785B1", `Mx Light Bluish Gray` = "#AFB5C7", `Mx Pink Red` = "#F45C40", `Mx Aqua Green` = "#27867E",
                    `Mx Light Yellow` = "#FFE371", `Mx Violet` = "#BD7D85", `Mx Medium Blue` = "#61AFFF", `Mx Light Orange` = "#F7AD63",
                    `Mx Charcoal Gray` = "#595D60", `Mx Tile Gray` = "#6B5A5A", `Mx Tile Brown` = "#330000", `Mx Tile Blue` = "#0057A6"
)
missing_colors <- tibble(bl_name = names(missing_colors), hex = missing_colors)

f <- function(r, g, b){
  sapply(seq_along(r), function(i) if(is.na(r[i])) as.character(NA) else rgb(r[i], g[i], b[i], maxColorValue = 255))
}

d <- tbl_df(d) %>% filter(!is.na(bl_name)) %>% select(c(1:3, 6:10, 13:14, 16:18)) %>% mutate(hex = f(r, g, b))
d$hex[match(missing_colors$bl_name, d$bl_name)] <- missing_colors$hex
legocolors <- select(d, -c(r, b, g)) %>% mutate_at(c(2, 4, 9:10), as.integer) %>%
  mutate(material = factor(tolower(material), levels = unique(tolower(material)))) %>% arrange(material, bl_id)
legopals <- split(legocolors$hex, legocolors$material)

bl_forsale_color <- function(color){
  l <- legocolors
  if(is.na(suppressWarnings(as.integer(color)))){
    color <- l$bl_id[l$bl_name == color]
    if(!length(color)) stop("Invalid BrickLink color name.", call. = FALSE)
  }
  if(!color %in% l$bl_id) stop("Invalid BrickLink color ID.", call. = FALSE)
  url <- paste0("https://www.bricklink.com/browseList.asp?colorID=", color, "&itemType=P&v=3")
  try(x <- xml2::read_html(url) %>% rvest::html_nodes("#id-main-legacy-table table") %>% rvest::html_table(fill = TRUE))
  if(inherits(x, "try-error")) return(0L)
  print(color)
  x <- dplyr::slice(x[[1]], 2)
  x <- x[!is.na(x)]
  x <- paste(unlist(x), collapse = "")
  x1 <- gsub(".*(\\)Brick \\(\\d+).*", "\\1", x)
  if(x1 == x) x1 <- ""
  x2 <- gsub(".*(\\)Plate \\(\\d+).*", "\\1", x)
  if(x2 == x) x2 <- ""
  sum(as.integer(substring(c(x1, x2), 9)), na.rm = TRUE)
}

bl_bp_forsale_score <- function(x){
  x <- sapply(x, bl_forsale_color)
  x <- x / max(x)
}

legocolors$bl_bp <- bl_bp_forsale_score(legocolors$bl_id) # takes a few minutes

d_rec <- arrange(legocolors, desc(bl_bp)) %>%
  filter(is.na(year_retired) & material == "solid" & bl_bp > 0.1) %>%
  select(bl_name, bl_bp)
d_rec

legocolors$recommended <- legocolors$bl_name %in% d_rec$bl_name

usethis::use_data(legocolors, legopals, overwrite = TRUE)


