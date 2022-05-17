# DPP: synthetic data packages

# synthetic, synthesize: "synthe"
# simulated, simulate, simulation: "simulat"
# anonymous, anonymize: "anonym"
# pseudonymous, pseudonymize: "pseudonym"
# deidentify, deidentification, de-identify, de-identification: "deidentif" & "de-identif" -> figure out how to include special characters (hyphens)

# THIS WORKS 
# filter_at is superseded,it can be replaced with across 
# for the links you need to replace ../.. and append/paste "https://cran.r-project.org/" at the beginning

library(rvest)
library(tidyverse)

cran_packages <- read_html("https://cran.r-project.org/web/packages/available_packages_by_date.html")

all_pkgs <- data.frame(
  name = cran_packages %>% html_elements("td:nth-child(2)") %>% html_text2(),
  description = cran_packages %>% html_elements("td~ td+ td") %>% html_text2(),
  pkg_links = cran_packages %>% html_elements("a") %>% html_attr("href")
)

# THIS WORKS
# mutate a new column to specify search term

## synthe

pkgs_synthe <- all_pkgs %>% 
  filter_at(.vars = vars(name, description),
            .vars_predicate = any_vars(str_detect(. , coll("synthe", ignore_case = TRUE))))

## simulat

pkgs_simulat <- all_pkgs %>% 
  filter_at(.vars = vars(name, description),
            .vars_predicate = any_vars(str_detect(. , coll("simulat", ignore_case = TRUE))))

## anonym 

pkgs_anonym <- all_pkgs %>% 
  filter_at(.vars = vars(name, description),
            .vars_predicate = any_vars(str_detect(. , coll("anonym", ignore_case = TRUE))))

## pseudonym

pkgs_pseudonym <- all_pkgs %>% 
  filter_at(.vars = vars(name, description),
            .vars_predicate = any_vars(str_detect(. , coll("pseudonym", ignore_case = TRUE))))

## deidentif

pkgs_deidentif <- all_pkgs %>% 
  filter_at(.vars = vars(name, description),
            .vars_predicate = any_vars(str_detect(. , coll("deidentif", ignore_case = TRUE))))

# GET ALL DATA FRAMES TOGETHER

cran_packages_privacy_list <- list(pkgs_synthe, pkgs_simulat, pkgs_anonym, pkgs_pseudonym, pkgs_deidentif)

cran_packages_privacy <- reduce(cran_packages_privacy_list, 
                                full_join, by = c("name",
                                                "description",
                                                "pkg_links"))
