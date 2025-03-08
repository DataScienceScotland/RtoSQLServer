# basic column name, datatype and length query
col_query <- function(database, schema, table_name) {
  glue::glue_sql("
  SELECT column_name, data_type, CHARACTER_MAXIMUM_LENGTH \\
  FROM INFORMATION_SCHEMA.COLUMNS \\
  WHERE TABLE_CATALOG = {database} \\
  AND TABLE_SCHEMA = {schema} \\
  AND TABLE_NAME = {table_name}", .con = DBI::ANSI())
}


update_col_query <- function(columns_info) {
  # To add the length of nvarchar column so appears as e.g. nvarchar(50)
  update_char <- glue::glue(
    "{columns_info[! is.na(columns_info$CHARACTER_MAXIMUM_LENGTH), 2]}\\
    ({as.character(columns_info\\
    [! is.na(columns_info$CHARACTER_MAXIMUM_LENGTH), 3])})"
  )

  columns_info$data_type[!is.na(columns_info$CHARACTER_MAXIMUM_LENGTH)] <-
    update_char

  # Now drop this column from df as not required
  columns_info$CHARACTER_MAXIMUM_LENGTH <- NULL
  columns_info
}

# Add the value ranges, counts, distinct counts to each column description
get_table_stats <- function(i, columns_info, schema, table_name) {
  col <- columns_info[i, "column_name"]
  data_type <- columns_info[i, "data_type"]

  # Generate the min/max query based on the data type
  min_max_query <- if (data_type != "bit") {
    glue::glue_sql("(SELECT MIN(CAST({`col`} AS NVARCHAR(225))) \\
                   FROM {`schema`}.{`table_name`} \\
                   WHERE {col} IS NOT NULL) AS minimum_value, \\
                   (SELECT MAX(CAST({`col`} AS NVARCHAR(225))) \\
                   FROM {`schema`}.{`table_name`} \\
                   WHERE {col} IS NOT NULL) AS maximum_value",
      .con = DBI::ANSI()
    )
  } else {
    glue::glue_sql("NULL AS minimum_value, NULL AS maximum_value")
  }

  # Building the full SQL query
  glue::glue_sql(
    "SELECT {col} AS column_name, {data_type} AS data_type, \\
(SELECT COUNT(*) FROM {`schema`}.{`table_name`}) AS row_count, \\
(SELECT COUNT(*) FROM {`schema`}.{`table_name`} WHERE {col} IS NULL) \\
AS null_count, \\
(SELECT COUNT(DISTINCT {`col`}) FROM {`schema`}.{`table_name`} \\
WHERE {col} IS NOT NULL) AS distinct_values, {min_max_query}",
    .con = DBI::ANSI()
  )
}

# building the metadata dataframe in stages...
get_metadata <- function(server,
                         database,
                         schema,
                         table_name,
                         summary_stats) {
  col_sql <- col_query(database, schema, table_name)
  columns_info <- execute_sql(server, database, col_sql, output = TRUE)
  columns_info <- update_col_query(columns_info)

  if (!summary_stats) {
    return(columns_info)
  }

  sql_parts <- lapply(seq_len(nrow(columns_info)),
    get_table_stats,
    columns_info = columns_info,
    schema = schema,
    table_name = table_name
  )

  full_sql <- glue::glue_collapse(sql_parts, sep = " UNION ALL ")

  columns_info <- execute_sql(server, database, full_sql, output = TRUE)

  columns_info
}


#' Return metadata about an existing database table
#'
#' Returns a dataframe of information about an existing table.
#' This includes the name of each column, its datatype and
#' (optionally) its range of values.
#'
#' @param server Server-instance where SQL Server database running.
#' @param database Name of SQL Server database where table is found.
#' @param schema Name of schema in SQL Server database where table is found.
#' @param table_name Name of the table.
#' @param summary_stats Add summary stats of each col to metadata output.
#' This includes ranges, number of distinct and number of NULL values.
#' Defaults TRUE, however much query time is much quicker if FALSE as
#' just returns col names and types.
#'
#' @return Dataframe of table / column metadata.
#' @export
#'
#' @examples
#' \dontrun{
#' db_table_metadata(
#'   database = "my_database",
#'   server = "my_server",
#'   table_name = "my_table",
#' )
#' }
db_table_metadata <- function(server,
                              database,
                              schema,
                              table_name,
                              summary_stats = FALSE) {
  if (!check_table_exists(
    server,
    database,
    schema,
    table_name
  )) {
    stop(glue::glue(
      "Table: {schema}.{table_name} does not exist in the database."
    ), call. = FALSE)
  }

  data <- get_metadata(server, database, schema, table_name, summary_stats)
  data[data$data_type == "nvarchar(-1)", "data_type"] <- "nvarchar(max)"
  data[] <- lapply(data, function(x) if (is.factor(x)) as.character(x) else x)
  data
}
