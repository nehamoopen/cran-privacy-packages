# HEADER -----------------------------------------------------------------------
#
# Data Privacy Project: R Packages for Handling Personal Data
# Author: Neha Moopen
# Date: 2022-05-19
#
# NOTES:  
#
# filter_at is superseded, it can be replaced with across 
# figure out how to include special characters (hyphens) for "de-identif"

# START SCRIPT -----------------------------------------------------------------

# LOAD LIBRARIES ---------------------------------------------------------------

library(rvest)
library(tidyverse)
library(writexl)

# SCRAPE WEB PAGE --------------------------------------------------------------

## read html page

cran_packages_html <- read_html("https://cran.r-project.org/web/packages/available_packages_by_date.html")

## extract relevant elements into dataframe

all_pkgs <- data.frame(
  name = cran_packages_html %>% html_elements("td:nth-child(2)") %>% html_text2(),
  description = cran_packages_html %>% html_elements("td~ td+ td") %>% html_text2(),
  pkg_links = cran_packages_html %>% html_elements("a") %>% html_attr("href")
)

## complete hyperlinks

all_pkgs <- all_pkgs %>%
  mutate(across("pkg_links", str_replace, "../..", "https://cran.r-project.org"))

# FILTER RELEVANT PACKAGES INTO DATAFRAMES -------------------------------------

## synthetic, synthesize: "synthe"

pkgs_synthe <- all_pkgs %>% 
  filter_at(.vars = vars(name, description),
            .vars_predicate = any_vars(str_detect(. , coll("synthe", ignore_case = TRUE)))) %>%
  mutate(. , search_term = "synthe")

## simulated, simulate, simulation: "simulat"

pkgs_simulat <- all_pkgs %>% 
  filter_at(.vars = vars(name, description),
            .vars_predicate = any_vars(str_detect(. , coll("simulat", ignore_case = TRUE)))) %>%
  mutate(. , search_term = "simulat")

## anonymous, anonymize: "anonym"

pkgs_anonym <- all_pkgs %>% 
  filter_at(.vars = vars(name, description),
            .vars_predicate = any_vars(str_detect(. , coll("anonym", ignore_case = TRUE)))) %>%
  mutate(. , search_term = "anonym")

## pseudonymous, pseudonymize: "pseudonym"

pkgs_pseudonym <- all_pkgs %>% 
  filter_at(.vars = vars(name, description),
            .vars_predicate = any_vars(str_detect(. , coll("pseudonym", ignore_case = TRUE)))) %>%
  mutate(. , search_term = "pseudonym")

## deidentify, deidentification, de-identify, de-identification: "deidentif" & "de-identif"

pkgs_deidentif <- all_pkgs %>% 
  filter_at(.vars = vars(name, description),
            .vars_predicate = any_vars(str_detect(. , coll("deidentif", ignore_case = TRUE)))) %>%
  mutate(. , search_term = "deidentif")

# MERGE DATA FRAMES ------------------------------------------------------------

cran_privacy_packages <- list(pkgs_synthe, pkgs_simulat, pkgs_anonym, pkgs_pseudonym, pkgs_deidentif) %>% 
  reduce(. , full_join, by = c("name",
                               "description",
                               "pkg_links",
                               "search_term"))

# WRITE TO EXCEL ---------------------------------------------------------------

write_xlsx(cran_privacy_packages,
           path = "data/cran_privacy_packages.xlsx",
           col_names = TRUE)

# END SCRIPT -------------------------------------------------------------------