
#' @title A Function to Read in a .ris File of Academic Papers
#'
#' @description This function reads in a .ris file of academic papers and then
#'              munges the output into 3 tidy interlinked data frames.
#' @inherit read_ris_internal
#'
#' @return 3 tidy data frames: papers, authors, authors_on_papers. Each paper has a unique id (paper_id),
#'         as does each paper (paper_id). Authors and papers are linked by authors_on_papers which links
#'         paper_id, and author_id.
#' @export
#' @import magrittr
#' @importFrom purrr transpose map
#' @importFrom dplyr rename mutate select full_join ungroup rowwise mutate_all mutate_at
#' @importFrom tibble as_data_frame tibble
#' @importFrom tidyr unnest
#' @examples
#'
read_ris <- function(file, ...) {

  ## Read in res file in messy format
  messy_papers <- read_ris_internal(file)

  ## convert to a tibble
  messy_papers <- messy_papers %>%
    transpose %>%
    as_data_frame %>%
    rename(paper_id = id) %>%
    mutate(paper_id = paper_id %>% as.numeric)

  ## Seperate authors on papers into seperate dataframe
  authors_on_papers <- messy_papers %>%
    select(paper_id, author.primary) %>%
    rename(author = author.primary) %>%
    mutate(author = author %>%
             map(~replace(., is.null(.), NA))) %>%
    mutate(author = author %>%
             map(~as_tibble(.))) %>%
    unnest(author) %>%
    rename(author = value)

  ## Split authors into a single data frame
  authors <- tibble(author = unique(authors_on_papers$author)) %>%
    mutate(author_id = 1:length(author))

  ##Join authors to assign correct author id to authors on papers
  authors_on_papers <- authors_on_papers %>%
    full_join(authors, by = "author") %>%
    select(-author)

  ## Drop authors from paper
  messy_papers <- messy_papers %>%
    select(-author.primary)

  ## Clean title and journal
  messy_papers <- messy_papers %>%
    mutate(title.secondary = title.secondary %>%
             map(~replace(., is.null(.), NA))) %>%
    mutate(journal = title.secondary %>%
             map(~nth(., 2))) %>%
    mutate(journal_temp = title.secondary %>%
             map(~first(.))) %>%
    mutate(journal = map2(journal,
                          journal_temp,
                          function(x,y) {ifelse(is.na(x), y, x)})
           ) %>%
    select(-title.secondary, -journal_temp) %>%
    rename(title = title.primary)

  ## Clean abstract - dropping repeated author/citation information
  messy_papers <- messy_papers %>%
    mutate(abstract = abstract %>%
             map(~replace(., is.null(.), NA))) %>%
    mutate(abstract = abstract %>%
             map(~first(.)))

  ## Clean date, dropping year as contains no new information
  messy_papers <- messy_papers %>%
    rowwise %>%
    mutate(date = paste(date$year,
                        date$month %>% replace(date$month %in% "", NA),
                        date$day %>% replace(date$day %in% "", NA), sep = "-") %>%
             str_split(pattern = "-NA")) %>%
    mutate(date = date[1] %>%
             ymd(truncated = 2)) %>%
    select(-year) %>%
    ungroup

  ## Clean (changing NULL to NA)
  messy_papers <- messy_papers %>%
    rowwise %>%
    mutate_all(.funs = funs(replace(., is.null(.), NA))) %>%
    ungroup

  ##Find variables that are ready to be unlisted
  papers <- messy_papers %>%
    mutate_at(.vars = vars(ris.type, type, paper_id, title, journal, volume, pages, abstract),
              .funs = funs(unlist(., recursive = FALSE)))

  out <- list(papers, authors, authors_on_papers)
  names(out) <- c("papers", "authors", "authors_on_papers")

  return(out)
  }
