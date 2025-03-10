test_that("SQL Server data type mapping works", {
  expect_equal(r_to_sql_data_type(iris$Species), "nvarchar(50)")
  expect_equal(r_to_sql_data_type(iris$Petal.Length), "float")
  # make a difftime type - not explicitly mapped
  df <- data.frame(
    col1 = difftime("2023-10-10 12:00:00", "2023-10-10 11:00:00")
  )
  expect_equal(r_to_sql_data_type(df$col1), "time")
})

test_that("Compatible character col check works", {
  expect_equal(compatible_cols(
    "float",
    "float"
  ), "compatible")
  expect_equal(compatible_cols(
    "float",
    "nvarchar(50)"
  ), "incompatible")
  expect_equal(compatible_cols(
    "nvarchar(max)",
    "nvarchar(50)"
  ), "compatible")
  expect_equal(compatible_cols(
    "nvarchar(50)",
    "nvarchar(max)"
  ), "resize")
  expect_equal(compatible_cols(
    "nvarchar(255)",
    "nvarchar(255)"
  ), "compatible")
  expect_equal(compatible_cols(
    "nvarchar(50)",
    "nvarchar(255)"
  ), "resize")
})

test_that("Can extract col size from nvarchar string", {
  expect_equal(get_nvarchar_size("nvarchar(max)"), "max")
  expect_equal(get_nvarchar_size("nvarchar(50)"), "50")
})

test_that("Char size to nvarchar type mapping works", {
  expect_equal(r_to_sql_character_sizes("10"), "nvarchar(50)")
  expect_equal(r_to_sql_character_sizes("255"), "nvarchar(255)")
  expect_equal(r_to_sql_character_sizes("4000"), "nvarchar(4000)")
  expect_equal(r_to_sql_character_sizes("4001"), "nvarchar(max)")
})


test_that("Incorrect connection gives error", {
  expect_error(create_sqlserver_connection("nonexistent", "nonexistent", 1))
})
