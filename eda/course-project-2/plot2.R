# Load required libraries
library(tidyverse)
library(here)

# Read datasets using readr::read_rds
pm_emissions <- readr::read_rds(here::here("eda/course-project-2/summarySCC_PM25.rds"))
src_classifications <- readr::read_rds(here::here("eda/course-project-2/Source_Classification_Code.rds"))

# Preview the dataset structure
tibble::glimpse(pm_emissions)
tibble::glimpse(src_classifications)

# Select appropriate columns by indexing
src_classifications <- src_classifications[, c(1:4, 7:10)]

# Get all the observations from `pm_emissions` that have a matching SCC
all_emissions_data <- pm_emissions %>%
  dplyr::left_join(
    src_classifications,
    by = c("SCC"),
  ) %>%
  dplyr::mutate(across(where(is.character), as.factor),
                year = as.factor(year)
  )

# Preview the dataset structure
tibble::glimpse(all_emissions_data)

baltimore_emissions <- all_emissions_data %>%
  dplyr::filter(fips == "24510")

# Aggregate emissions by year
baltimore_emissions_by_year <- baltimore_emissions %>%
  dplyr::group_by(year) %>%
  dplyr::summarise(
    total_emissions = sum(Emissions, na.rm = TRUE)
  )

# Create bar plot
barplot(
  baltimore_emissions_by_year$total_emissions,
  names.arg = baltimore_emissions_by_year$year,
  xlab = "Year",
  ylab = "Total PM2.5 emitted (in tonnes)",
  main = "Total PM2.5 emissions from all four emission types in Baltimore between 1999 and 2008",
  col = "violet"
)
