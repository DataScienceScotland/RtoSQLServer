% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/drop_table_from_db.R
\name{drop_table_from_db}
\alias{drop_table_from_db}
\title{Drop SQL Server table from database}
\usage{
drop_table_from_db(
  server,
  database,
  schema,
  table_name,
  versioned_table = FALSE,
  silent = FALSE
)
}
\arguments{
\item{server}{Server and instance where SQL Server database found.}

\item{database}{Database containing the table to be dropped.}

\item{schema}{Name of schema containing table to be dropped.}

\item{table_name}{Name of the table to be dropped.}

\item{versioned_table}{Is this a versioned table. Legacy argument no
longer used. This is now checked every time regardless of T or F input.}

\item{silent}{If TRUE do not give message that dropping complete.
Defaults to FALSE.}
}
\description{
Drop specified table. Check if versioned table. If so attempt to disable
versioning and drop history table too if so. Extra permissions may be
required to drop a versioned table so contact system admin if
receive an error showing this is the case.
}
\examples{
\dontrun{
drop_table_from_db(
  database = "my_database",
  server = "my_server",
  schema = "my_schema",
  table_name = "table_to_drop"
)
}
}
