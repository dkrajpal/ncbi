#' @autoImports
getID <- function(id, db) {  
  if (is.numeric(id) || !any(is.na(suppressWarnings(as.numeric(id))))) {
    epost(id, db)
  } else {
    esearch(id, db, usehistory=TRUE)
  }
}


#' @autoImports
sequence_args <- function(gi, db, rettype, retmax, ...) {
  
  rettype <- if (is.null(rettype)) {
    NULL
  } else {
    rettype <- switch(db,
                      protein=match.arg(rettype, c("fasta", "gp", "gpc", "ft",
                                                   "seqid", "acc", "native")),
                      nuccore=match.arg(rettype, c("fasta", "gb", "gbc", "ft",
                                                   "gbwithparts", "fasta_cds_na",
                                                   "fasta_cds_aa", "seqid", "acc",
                                                   "native")),
                      nucgss=match.arg(rettype, c("fasta", "gb", "gbc",
                                                  "seqid", "acc", "native", "gss")),
                      nucest=match.arg(rettype, c("fasta", "gb", "gbc",
                                                  "seqid", "acc", "native", "est")),
                      popset=match.arg(rettype, c("fasta", "gb", "gbc", )))
  }
  
  args <- c(list(...), list(rettype = rettype, retmax = retmax))
  args <- c(args, list(id = getID(id=gi, db=db)))
  if (is.null(args[["retmode"]]))
    args <- c(args, list(retmode = switch(rettype %||% "asn.1", fasta = "xml",
                                          gp = "text", gpc = "xml", gb = "text",
                                          gbc = "text", gbwithparts = "text",
                                          fasta_cds_na = "text", fasta_cds_aa = "text", 
                                          ft = "text", seqid = "text", acc = "text",
                                          native = "xml", gss = "text", est = "text",
                                          asn.1 = "text")))
  args
}


#' @autoImports
pubmed_args <- function(pmid, rettype, retmax, ...) {
  rettype <- if (is.null(rettype)) {
    NULL
  } else {
    match.arg(rettype, c("medline", "uilist", "abstract"))
  }
  
  args <- c(list(...), list(rettype = rettype, retmax = retmax))
  args <- c(args, list(id = getID(id=pmid, db="pubmed")))
  if (is.null(args[["retmode"]]))
    args <- c(args, list(retmode = switch(rettype %||% "xml",
                                          medline = "text",
                                          uilist = "text",
                                          abstract = "text",
                                          xml = "xml")))
  args
}


#' @autoImports
taxonomy_args <- function(taxid, rettype, retmax, ...) {
  rettype <- if (is.null(rettype)) {
    NULL
  } else {
    match.arg(rettype, "uilist")
  }
  
  args <- c(list(...), list(rettype = rettype, retmax = retmax))
  args <- c(args, list(id = getID(id=taxid, db="taxonomy")))
  if (is.null(args[["retmode"]]))
    args <- c(args, list(retmode = switch(rettype %||% "xml",
                                          uilist = "xml",
                                          xml = "xml")))
  args
}


#' @importFrom rentrez efetch
#' @importFrom rentrez efetch.batch
#' @autoImports
fetch_records <- function(args, maxrec = 500) {
  if (count(args$id) > maxrec && args$retmax %||% Inf > maxrec) {
    response <- do.call(efetch.batch, c(args, list(chunk_size = 500)))
  } else {
    response <- do.call(efetch, args)
  }
  response <- content(response)
  response
}
