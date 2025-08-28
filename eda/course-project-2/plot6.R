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

la_and_baltimore_vehicular_emissions <- all_emissions_data %>%
  dplyr::filter(fips %in% c("06037", "24510"),
                type == "ON-ROAD")

vehicular_emissions_by_fips <- la_and_baltimore_vehicular_emissions %>%
  dplyr::group_by(
    area = dplyr::recode(
      fips,
      "06037" = "Los Angeles County",
      "24510" = "Baltimore City"
    ),
    year
  ) %>%
  dplyr::summarise(
    total_emissions = sum(Emissions, na.rm = TRUE),
    .groups = "drop"
  )

vehicular_emissions_yoy <- vehicular_emissions_by_fips %>%
  arrange(area, year) %>%
  group_by(area) %>%
  mutate(
    yoy_pct_change = (total_emissions - lag(total_emissions)) / lag(total_emissions) * 100
  ) %>%
  ungroup()

ggplot(
  vehicular_emissions_yoy,
  aes(year,
    yoy_pct_change,
    fill = area
  )
) +
  geom_bar(
    stat = "identity",
    position = "dodge",
    width = 0.75
  ) +
  scale_x_discrete(
    limits = c("2002", "2005", "2008")
  ) +
  scale_y_continuous(
    limits = c(-100, 100),
    expand = c(0, 0),
    labels = function(x) paste0(x, "%")
  ) +
  theme_classic() +
  labs(
    x = "Year",
    y = "YOY % change in PM2.5 emissions",
    title = "YOY percentage change in motor vehicle PM2.5 emissions by area",
    fill = "Area"
  ) +
  theme(
    axis.ticks.length = grid::unit(0.2, "cm"),
    axis.title = element_text(face = "bold"),
    plot.title = element_text(hjust = 0.5, face = "bold"),
    plot.margin = margin(0.5, 0.5, 0.5, 0.5, "cm")
  ) +
  geom_text(
    aes(label = paste0(round(yoy_pct_change, 2), "%")),
    position = position_dodge(width = 0.75),
    vjust = -0.25,
    size = 3
  ) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black")
