context("Color mapping")

test_that("functions return as expected", {
  expect_equal(hex_to_color(c("#ff0000", "#ff0001")), c("red", "~red"))
  expect_equal(hex_to_legocolor("#ff0000"), "~Trans-Red")
  expect_equal(hex_to_legocolor("#ff0000", material = "solid"), "~Red")
  expect_equal(legocolor_to_hex("Red"), "#B40000")
  expect_equal(hex_to_color(legocolor_to_hex("Red")), "~red3")
})
