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

baltimore_emissions_by_type <- baltimore_emissions %>%
  dplyr::group_by(type, year) %>%
  dplyr::summarise(
    total_emissions = sum(Emissions, na.rm = TRUE),
    .groups = "drop"
  )

ggplot2::ggplot(
  baltimore_emissions_by_type,
  aes(year, total_emissions, fill = type)
) +
  ggplot2::geom_bar(
    stat = "identity",
    width = 0.75,
    position = "dodge"
  ) +
  ggplot2::scale_y_continuous(
    limits = c(0, 2500),
    expand = c(0, 0)
  ) +
  ggplot2::theme_classic() +
  ggplot2::labs(
    x = "Year",
    y = "Total PM2.5 emitted (in tonnes)",
    title = "Total PM2.5 emissions in Baltimore City from all four emission types between 1999 and 2008",
    fill = "Emission type"
  ) +
  ggplot2::theme(
    axis.ticks.length = grid::unit(0.2, "cm"),
    axis.title = element_text(face = "bold"),
    plot.title = element_text(hjust = 0.5, face = "bold"),
    plot.margin = margin(0.5, 0.5, 0.5, 0.5, "cm")
  ) +
  ggplot2::geom_text(
    aes(label = round(total_emissions, 2)),
    position = position_dodge(width = 0.75),
    vjust = -0.25,
    size = 3
  )
