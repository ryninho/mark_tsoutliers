### This script takes a csv and returns a csv with the primary key and labeled
### outliers. It can optionally include the outlier types and tstats as well.
### For more information see the `tsoutliers` package.

library(argparse)
library(tsoutliers)

parse_cmd_args <- function(parser) {
  parser <- ArgumentParser()

  parser$add_argument("-i", "--input_file",
    help = "Path of input .csv with time series")

  parser$add_argument("-k", "--primary_key_name",
    help = "Column name of primary key. Overriden if --primary_key_index used")

  parser$add_argument("-p", "--primary_key_index", type = "integer",
    help = "Column index (from 1) of primary key. Overrides --primary_key_name")

  parser$add_argument("-v", "--series_name",
    help = "Column name of series. Setting --series_index overrides this")

  parser$add_argument("-x", "--series_index", type = "integer",
    help = "Column index (from 1) of series. Overrides --series_name setting")

  parser$add_argument("-r", "--reverse_series",
    action = "store_true", default = FALSE,
    help = "Locate (and return) outliers in reverse time series order")

  parser$add_argument("-c", "--critical_value", type = "double",
    help = "Critical value. Otherwise set by tsoutliers based on sample size")

  parser$add_argument("--AO",
    action = "store_true", default = FALSE,
    help = "Identify additive outliers. Overrides default of {AO, TC}")

  parser$add_argument("--LS",
    action = "store_true", default = FALSE,
    help = "Identify level shifts. Overrides default of {AO, TC}")

  parser$add_argument("--TC",
    action = "store_true", default = FALSE,
    help = "Identify temporary changes. Overrides default of {AO, TC}")

  parser$add_argument("--IO",
    action = "store_true", default = FALSE,
    help = "Find innovative outliers. Overrides default of {AO, TC}")

  parser$add_argument("--SLS",
    action = "store_true", default = FALSE,
    help = "Find seasonal level shifts. Overrides default of {AO, TC}")

  parser$add_argument("-o", "--output_file", default = "tsoutliers.csv",
    help = "Path of output .csv")

  parser$add_argument("--return_outlier_type",
    action = "store_true", default = FALSE,
    help = "Return outlier type [default %(default)s]")

  parser$add_argument("--return_outlier_magnitude",
    action = "store_true", default = FALSE,
    help = "Return outlier magnitude ('coefhat' value) [default %(default)s]")

  parser$add_argument("--return_outlier_tstat",
    action = "store_true", default = FALSE,
    help = "Return outlier t-statistic [default %(default)s]")

  parser$add_argument("-g", "--generate_plot",
    action = "store_true", default = FALSE,
    help = "Generate plot of outliers [default %(default)s]")

  parser$add_argument("--plot_path", default = "tsoutliers.png",
    help = "File path for outlier plot. Plot type is .png")

  parser$parse_args()
}

args <- parse_cmd_args(ArgumentParser())

series_df <- read.csv(args$input_file, as.is = TRUE)

if(args$reverse_series) {
  series_df <- series_df[seq(dim(series_df)[1],1),]
}

if(!is.null(args$primary_key_index)) {
  pkey <- series_df[, args$primary_key_index]
} else {
  pkey <- series_df[, args$primary_key_name]
}

if(!is.null(args$series_index)) {
  s <- ts(series_df[, args$series_index])
} else {
  s <- ts(series_df[, args$series_name])
}

tso_outlier_types <- c()
if(args$AO) {tso_outlier_types <- c(tso_outlier_types, "AO")}
if(args$LS) {tso_outlier_types <- c(tso_outlier_types, "LS")}
if(args$TC) {tso_outlier_types <- c(tso_outlier_types, "TC")}
if(args$IO) {tso_outlier_types <- c(tso_outlier_types, "IO")}
if(args$SLS) {tso_outlier_types <- c(tso_outlier_types, "SLS")}
paste(tso_outlier_types, collapse = ", ")
if(length(tso_outlier_types) == 0) {tso_outlier_types <- c("AO", "TC")}

print("Identifying time series outliers...")
mod <- tso(s, type = tso_outlier_types, cval = args$critical_value)
print("... outliers identified.")
out <- mod$outliers

tso_df <- data.frame(pkey = pkey, series = s, tsoutlier = FALSE)

for(ix in seq_along(out$ind)) {
  tso_df[out$ind[ix], "tsoutlier"] <- TRUE
  if(args$return_outlier_type) {
    tso_df[out$ind[ix], "tsoutlier_type"] <- out$type[ix]
    }
  if(args$return_outlier_magnitude) {
    tso_df[out$ind[ix], "tsoutlier_coefhat"] <- out$coefhat[ix]
    }
  if(args$return_outlier_tstat) {
    tso_df[out$ind[ix], "tsoutlier_tstat"] <- out$tstat[ix]
    }
}

write.csv(tso_df, args$output_file, row.names = FALSE, na = "")

if(args$generate_plot) {
  png(args$plot_path)
  plot(mod)
  dev.off()
}

print("mark_tsoutliers complete!")
