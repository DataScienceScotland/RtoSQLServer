% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/db_table_metadata.R
\name{db_table_metadata}
\alias{db_table_metadata}
\title{Return metadata about an existing database table}
\usage{
db_table_metadata(server, database, schema, table_name, summary_stats = FALSE)
}
\arguments{
\item{server}{Server-instance where SQL Server database running.}

\item{database}{Name of SQL Server database where table is found.}

\item{schema}{Name of schema in SQL Server database where table is found.}

\item{table_name}{Name of the table.}

\item{summary_stats}{Add summary stats of each col to metadata output.
This includes ranges, number of distinct and number of NULL values.
Defaults TRUE, however much query time is much quicker if FALSE as
just returns col names and types.}
}
\value{
Dataframe of table / column metadata.
}
\description{
Returns a dataframe of information about an existing table.
This includes the name of each column, its datatype and
(optionally) its range of values.
}
\examples{
\dontrun{
db_table_metadata(
  database = "my_database",
  server = "my_server",
  table_name = "my_table",
)
}
}
