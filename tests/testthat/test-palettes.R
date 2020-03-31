test_that("palettes return as expected", {
  expect_equal(lc_terrain(), lc_terrain(11))
  expect_equal(lc_terrain(3), .lc_terrain[c(1, 6, 11)])
  expect_equal(length(lc_terrain(20)), 20)

  expect_equal(length(lc_topo()), 5)
  expect_equal(length(lc_heat()), 5)
})
