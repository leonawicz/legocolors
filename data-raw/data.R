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

missing_colors <- c(`Chrome Antique Brass` = "#645A4C", `Chrome Black` = "#544E4F", `Chrome Blue` = "#5C66A4",
                    `Chrome Green` = "#3CB371", `Chrome Pink` = "#AA4D8E", `Metallic Gold` = "#B8860B", `Metallic Green` = "#BDB573",
                    `Glitter Trans-Light Blue` = "#68BCC5", `Glitter Trans-Neon Green` = "#C0F500", `Speckle Black-Silver` = "#7C7E7C",
                    `Speckle Black-Copper` = "#5F4E47", `Speckle Black-Gold` = "#AB9421", `Mx Clear` = "#FFFFFF",
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

d <- tibble(d) %>% filter(!is.na(bl_name)) %>% select(c(1:8, 10:11, 13:16)) %>% mutate(hex = f(r, g, b))
d$hex[match(missing_colors$bl_name, d$bl_name)] <- missing_colors$hex
legocolors <- select(d, -c(r, b, g)) %>% mutate_at(c(2, 4, 6, 9:10), as.integer) %>%
  mutate(material = factor(tolower(material), levels = unique(tolower(material)))) %>% arrange(material, bl_id)

bl_color_data <- function(){
  url <- "https://www.bricklink.com/catalogColors.asp?utm_content=subnav"
  x <- xml2::read_html(url) %>% rvest::html_nodes("#id-main-legacy-table table table")
  x <- lapply(x, function(x){
    x <- rvest::html_table(x)
    x <- x[, !is.na(x[1, ])]
    names(x) <- x[1, ]
    x <- x[-1, ]
    tibble(x) %>%
      mutate_at(c(1, 3:6), as.integer) %>%
      mutate_if(is.integer, list(~case_when(is.na(.) ~ 0L, TRUE ~ .)))
  })
  bind_rows(x) %>%
    mutate(availability = Parts + `In Sets` + `For Sale`,
           availability = availability / max(availability)) %>%
    arrange(desc(availability))

}

x <- bl_color_data()

legocolors <- filter(legocolors, !is.na(hex))

legopals <- split(legocolors$hex, legocolors$material)

legocolors$bl_bp <- x$availability[match(legocolors$bl_id, x$ID)]

d_rec <- arrange(legocolors, desc(bl_bp)) %>%
  filter(is.na(year_retired) & material == "solid" & bl_bp > 0.03 &
           !grepl("^Bright|Nougat|Dark Azure|Magenta|Lavender", bl_name)) %>%
  select(bl_name, bl_bp) %>% distinct()
data.frame(d_rec)

legocolors$recommended <- legocolors$bl_name %in% d_rec$bl_name
legocolors$bl_bp <- NULL

usethis::use_data(legocolors, legopals, overwrite = TRUE)

bl_terrain_names <- c(
  "Dark Green", "Green", "Olive Green", "Sand Green", "Lime", "Yellow",
  "Dark Orange", "Reddish Brown", "Dark Tan", "Tan", "White"
)
bl_topo_names <- c("Tan", "Yellow", "Lime", "Medium Blue", "Dark Blue")
bl_heat_names <- c("White", "Yellow", "Orange", "Red", "Dark Red")

.lc_terrain <- legocolors$hex[match(bl_terrain_names, legocolors$bl_name)]
.lc_topo <- legocolors$hex[match(bl_topo_names, legocolors$bl_name)]
.lc_heat <- legocolors$hex[match(bl_heat_names, legocolors$bl_name)]

usethis::use_data(.lc_terrain, .lc_topo, .lc_heat,
                  internal = TRUE, overwrite = TRUE)
