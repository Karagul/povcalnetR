# Helpers
api_handle <- function() "povcalnet/povcalnetapi.ashx"

format_data <- function(x, coverage, aggregate) {

  if (aggregate == FALSE){
    x <- format_data_cl(x = x,
                        coverage = coverage)
  } else {
    x <- format_data_aggregate(x = x)
  }
  return(x)
}



format_data_cl <- function(x, coverage) {
  # CHECK
  assertthat::assert_that(
    all.equal(names(x), povcal_col_names)
  )

  x <- dplyr::select(x,
                     "countrycode" = "CountryCode",
                     "countryname" = "CountryName",
                     "regioncode" = "RegionCode",
                     "coveragetype" = "CoverageType",
                     "year" = "RequestYear",
                     "datayear" = "DataYear",
                     "datatype" = "DataType",
                     "isinterpolated" = "isInterpolated",
                     "usemicrodata" = "useMicroData",
                     "ppp" = "PPP",
                     "povertyline" = "PovertyLine",
                     "mean" = "Mean",
                     "headcount" = "HeadCount",
                     "povertygap" = "PovGap",
                     "povertygapsq" = "PovGapSqr",
                     "watts" = "Watts",
                     "gini" = "Gini",
                     "median" = "Median",
                     "mld" = "pr.mld",
                     "polarization" = "Polarization",
                     "population" = "ReqYearPopulation",
                     "decile1" = "Decile1",
                     "decile2" = "Decile2",
                     "decile3" = "Decile3",
                     "decile4" = "Decile4",
                     "decile5" = "Decile5",
                     "decile6" = "Decile6",
                     "decile7" = "Decile7",
                     "decile8" = "Decile8",
                     "decile9" = "Decile9",
                     "decile10" = "Decile10"
  )

  # rename data_type to be more explicit
  x$datatype <- datatype_lkup[x$datatype]

  if (nrow(x) > 0) {
    # replace invalid values to missing
    rvars <- c("median", "polarization", "gini", "mld",
               stringr::str_subset(names(x), "^decile"))

    x <- naniar::replace_with_na_at(data = x,
                                    .vars = rvars,
                                    condition = ~.x  %in% c(-1, 0))
  }

  return(tibble::as_tibble(x))
}


format_data_aggregate <- function(x) {
  # CHECK
  assertthat::assert_that(
    all.equal(names(x), povcal_col_names_agg)
  )

  x <- dplyr::select(x,
                     "regiontitle" = "regionTitle",
                     "regioncode" = "regionCID",
                     "year" = "requestYear",
                     "povertyline" = "povertyLine",
                     "mean" = "mean",
                     "headcount" = "hc",
                     "povertygap" = "pg",
                     "povertygapsq" = "p2",
                     "population" = "population"
  )

  return(tibble::as_tibble(x))
}

assign_country <- function(country) {

  if (length(country) == 1 & all("all" %in% country)) {
    country <- all_countries
  } else {
    country
  }
}


assign_coverage <- function(coverage, country) {

  if (coverage == "all") {
    country <- unname(all_coverage[names(all_coverage) %in% country])
    return(country)
  } else if (coverage == "national") {
    coverage_codes <- national_coverage_lkup[country]
    coverage_codes <- coverage_codes[!is.na(coverage_codes)]
    country <- paste(names(coverage_codes), coverage_codes, sep = "_")
    return(country)
  } else {
    coverage <- unname(coverage_lkup[coverage])
    country <- paste(country, coverage, sep = "_")
    return(country)
  }
}


handle_empty_response <- function(x, aggregate) {
  if (aggregate == FALSE) {
    x <- data.frame(matrix(ncol = length(povcal_col_names), nrow = 0))
    colnames(x) <- povcal_col_names
    return(x)
  } else if (aggregate == TRUE) {
    x <- data.frame(matrix(ncol = length(povcal_col_names_agg), nrow = 0))
    colnames(x) <- povcal_col_names_agg
    return(x)
  }
}
