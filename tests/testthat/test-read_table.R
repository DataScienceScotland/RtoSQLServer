test_that("select sql works", {
  test_sql <- glue::glue_sql(
    "SELECT \"col_a\", \"col_b\" FROM \"test_schema\".\"test_tbl\" \\
    WHERE \"col_a\" = 'test1' AND \"col_b\" = 'test2';"
  )

  select_list <- c("col_a", "col_b")

  filter_ex <- format_filter("col_a == 'test1' & col_b == 'test2'")


  mockery::stub(create_read_sql, "format_filter", filter_ex)

  test_read_md <- readRDS(test_path("testdata", "test_read_md.rds"))


  expect_equal(create_read_sql(
    schema = "test_schema",
    select_list = select_list,
    table_name = "test_tbl",
    table_metadata = test_read_md,
    filter_stmt = "col_a == 'test1' & col_b == 'test2'",
    cast_datetime2 = TRUE
  ), test_sql)
})
