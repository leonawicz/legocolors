context("Color mapping")

test_that("functions return as expected", {
  expect_equal(hex_to_color(c("#ff0000", "#ff0001")), c("red", "~red"))
  expect_equal(hex_to_legocolor("#ff0000"), "~Trans-Red")
  expect_equal(hex_to_legocolor("#ff0000", material = "solid"), "~Red")
  expect_equal(legocolor_to_hex("Red"), "#B40000")
  expect_equal(hex_to_color(legocolor_to_hex("Red")), "~red3")

  expect_equal(hex_to_color("#FF0000"), "red")
  expect_equal(hex_to_color("#FF0001", prefix = "*"), "*red")
  expect_equal(hex_to_color("#FF0001"), "~red")
  expect_equal(hex_to_color("#FF0001", approx = FALSE), as.character(NA))

  expect_equal(hex_to_legocolor("#B40000"), "Red")
  expect_equal(hex_to_legocolor("#B40001", prefix = "*"), "*Red")
  expect_equal(hex_to_legocolor("#B40001"), "~Red")
  expect_equal(hex_to_legocolor("#B40001", approx = FALSE), as.character(NA))

  expect_error(hex_to_legocolor("#B40000", material = "a"), "Invalid material. See `legocolors`.")
})

test_that("functions return as expected", {
  skip_on_cran()
  expect_is(view_legopal("solid"), "NULL")
  expect_is(view_legopal(rainbow(9), show_labels = TRUE, label_size = 0.7), "NULL")
})
unlink("Rplots.pdf", force = TRUE)
