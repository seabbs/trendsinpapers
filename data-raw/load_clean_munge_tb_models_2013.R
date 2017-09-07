
if (!file.exists("./data-raw/TB_papers.csv") |
    !file.exists("./data-raw/TB_authors.csv") |
    !file.exists("./data-raw/TB_authors_on_papers.csv")) {

  ## Load in packages
  library(trendsinpapers)
  library(zeallot)

  ## Read in TB modelling data
  c(TB_papers, TB_authors, TB_authors_on_papers) %<-% read_ris("data-raw/TBmodelling_Jun2013.ris")

  ## Add TB authors data etc to the package
  devtools::use_data(TB_papers, overwrite = TRUE)
  devtools::use_data(TB_authors, overwrite = TRUE)
  devtools::use_data(TB_authors_on_papers, overwrite = TRUE)

  ##Add TB authors data etc as raw csv
  write_csv(TB_papers, "data-raw/TB_papers.csv")
  write_csv(TB_authors, "data-raw/TB_authors.csv")
  write_csv(TB_authors_on_papers, "data-raw/TB_authors_on_papers.csv")
}

