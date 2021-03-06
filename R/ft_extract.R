#' @title Extract text from a single pdf document
#' 
#' @description `ft_extract` attemps to make it easy to extract text from 
#' PDFs, using \pkg{pdftools}. Inputs can be either paths to PDF
#' files, or the output of [ft_get()] (class `ft_data`). 
#' 
#' @export
#' @param x Path to a pdf file, or an object of class `ft_data`, the 
#' output from [ft_get()]
#' @return An object of class `pdft_char` in the case of character input, 
#' or of class `ft_data` in the case of `ft_data` input
#' @examples \dontrun{
#' path <- system.file("examples", "example1.pdf", package = "fulltext")
#' (res <- ft_extract(path))
#' 
#' # use on output of ft_get() to extract pdf to text
#' ## arxiv
#' res <- ft_get('cond-mat/9309029', from = "arxiv")
#' res2 <- ft_extract(res)
#' res$arxiv$data
#' res2$arxiv$data
#' res2$arxiv$data$data[[1]]$data
#' 
#' ## biorxiv
#' res <- ft_get('10.1101/012476')
#' res2 <- ft_extract(res)
#' res$biorxiv$data
#' res2$biorxiv$data
#' res2$biorxiv$data$data[[1]]$data
#' }
ft_extract <- function(x) {
  UseMethod("ft_extract")
}

#' @export
ft_extract.character <- function(x) {
  if (!file.exists(x)) stop("File does not exist", call. = FALSE)
  res <- crminer::crm_extract(x)
  structure(list(meta = res$info, data = res$text), class = "pdft_char", 
            path = x)
}

#' @export
ft_extract.ft_data <- function(x) {
  do_extraction(x)
}

do_extraction <- function(x) {
  structure(lapply(x, function(y) {
    for (i in seq_along(y$data$path)) {
      y$data$data[[i]] <- crminer::crm_extract(y$data$path[[i]])$text
    }
    y$data$data <- unclass(y$data$data)
    return( y )
  }), class = "ft_data")
}

#' @export
print.pdft_char <- function(x, ...) {
  cat("<document>", attr(x, "path"), "\n", sep = "")
  cat("  Title: ", x$meta$keys$Title, "\n", sep = "")
  cat("  Producer: ", x$meta$keys$Producer, "\n", sep = "")
  cat("  Creation date: ", as.character(as.Date(x$meta$created)), "\n", 
      sep = "")
}
