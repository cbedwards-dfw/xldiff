test_that("score_df_match works", {
  df2 = df1 = as.data.frame(matrix(1:10, 2, 5))
  ## currently: perfect match
  expect_equal(score_df_match(df1, df2), 1)
  ## change one value
  df2[1,1] = df2[1,1] + .1
  ## now: should be 90% match
  expect_equal(score_df_match(df1, df2), 0.9)
  ## Does the rounding work right? set digits = 0 to ignore the addition of 0.1 above
  expect_equal(score_df_match(df1, df2, digits = 0), 1)
  ## If the two matrices don't match, should get value of 0
  expect_equal(score_df_match(df1, df2+.1), 0)
})
