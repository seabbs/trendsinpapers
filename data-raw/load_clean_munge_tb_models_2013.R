
if (!file.exists("./data-raw/TB_papers.csv") |
    !file.exists("./data-raw/TB_authors.csv") |
    !file.exists("./data-raw/TB_authors_on_papers.csv")) {

  ## Load in packages
  library(trendsinpapers)
  library(zeallot)

  ## Read in TB modelling data
  c(TB_papers, TB_authors, TB_authors_on_papers) %<-% read_ris("data-raw/TBmodelling_Jun2013.ris")

  ## Hand clean journal names so that various spellings are grouped
  table(TB_papers$journal)

   TB_papers <- TB_papers %>%
    mutate(journal = journal %>%
             recode(`Trop.Med.Intern.Health` = "Trop Med Int Health",
                    `Tubercle` = "Tubercle and Lung Disease",
                    `Tuber Lung Dis` = "Tubercle and Lung Disease",
                    `Theor Popul Biol` = "Theoretical population biology",
                    `Stat.Med.` = "Stat Med",
                    `Science (New York, N.Y.)` = "Science",
                    `Sci Transl Med` = "Science Translational Medicine",
                    `S.Afr.Med.J.` = "S Afr Med J",
                    `Proc Natl Acad Sci U S A` = "Proceedings of the National Academy of Sciences of the USA",
                    `PLoS ONE` = "PLoS One",
                    `PLoS one` = "PLoS One",
                    `PloS one` = "PLoS One",
                    `PLoS medicine` = "PLoS Med",
                    `J.Theor.Biol` = "J Theor Biol",
                    `J.Theor.Biol.` = "J Theor Biol",
                    `Journal of Mathematical Biology` = "J Math Biol",
                    `Journal of Infectious Diseases` = "J Infect Dis",
                    `Journal of Immunology` = "J Immunol",
                    `The international journal of tuberculosis and lung disease : the official journal of the International Union against Tuberculosis and Lung Disease` = "International Journal of Tuberculosis and Lung Disease",
                    `Int.J.Tuberc.Lung Dis.` = "International Journal of Tuberculosis and Lung Disease",
                    `Int J Tuberc Lung Dis` = "International Journal of Tuberculosis and Lung Disease",
                    `International Journal of Epidemiology` = "Int J Epidemiol",
                    `Indian J.Pub.Hlth.` = "Indian Journal of Public Health",
                    `Indian J.Tuberc.` = "Indian J Tuberc",
                    `Ind. J. Tub.` = "Indian J Tuberc",
                    `Europeran Respiratory Journal` = "European Respiratory Journal",
                    `Eur.Respir.J.` = "European Respiratory Journal",
                    `Eur Respir J` = "European Respiratory Journal",
                    `Bmc Public Health` = "BMC Public Health",
                    `AIHAJ` = "Am Ind Hyg Assoc J ", .default = levels(journal))
    )

  ## Add TB authors data etc to the package
  devtools::use_data(TB_papers, overwrite = TRUE)
  devtools::use_data(TB_authors, overwrite = TRUE)
  devtools::use_data(TB_authors_on_papers, overwrite = TRUE)

  ##Add TB authors data etc as raw csv
  write_csv(TB_papers, "data-raw/TB_papers.csv")
  write_csv(TB_authors, "data-raw/TB_authors.csv")
  write_csv(TB_authors_on_papers, "data-raw/TB_authors_on_papers.csv")
}

