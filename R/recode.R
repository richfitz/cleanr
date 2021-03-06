##' Recode a set of data according to rules. Amazing documentation!
##'
##' @title Recode a data set
##' @param data A data set
##' @param rules Some rules
##' @export
recode <- function(data, rules) {
  for (v in names(rules)) {
    data <- recode_apply(v, data, rules[[v]])
  }
  data
}

recode_apply <- function(name, data, rule) {
  if ("from" %in% names(rule)) {
    x <- unname(data[rule$from])
    fun <- setdiff(names(rule), "from")
  } else {
    x <- unname(data[name])
    fun <- names(rule)
  }

  for (f in fun) {
    r <- rule[[f]]
    i <- vapply(r, is_variable, logical(1))
    if (any(i)) {
      r[i] <- lapply(r[i], function(x) data[[sub("^\\$", "", x)]])
    }
    ## TODO: using do.call here is really suboptimal when 'x' might be
    ## large.  More background: http://rpubs.com/hadley/do-call2
    x <- list(do.call(f, c(x, r), quote=TRUE))
  }

  data[name] <- x
  data
}


is_variable <- function(x) {
  is.character(x) && length(x) == 1L && grepl("^\\$", x)
}
