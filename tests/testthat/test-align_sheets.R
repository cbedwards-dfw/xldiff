test_that("pad_sheets works", {
  df1 <-  mtcars[1:5,]
  df2 <- mtcars[1:3,]
  res <- pad_sheets(df1, df2)
  expect_equal(dim(res[[1]]), dim(res[[2]]))

  df1 <-  mtcars[1:3,]
  df2 <- mtcars[1:5,]
  res <- pad_sheets(df1, df2)
  expect_equal(dim(res[[1]]), dim(res[[2]]))

  df1 <-  mtcars[, 1:5]
  df2 <- mtcars[, 1:3]
  res <- pad_sheets(df1, df2)
  expect_equal(dim(res[[1]]), dim(res[[2]]))

  df1 <-  mtcars[, 1:3]
  df2 <- mtcars[, 1:5]
  res <- pad_sheets(df1, df2)
  expect_equal(dim(res[[1]]), dim(res[[2]]))
})
