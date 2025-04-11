# Load required libraries
library(data.table)
library(lubridate)
library(dplyr)

# Import dataset as data frame
dataset <- data.table::fread("household_power_consumption.txt",
                             sep = ";",
                             na.strings = "?",
                             header = TRUE)

# Create combined datetime variable
dataset_formatted <- dataset %>%
  mutate(
    Date = lubridate::dmy(Date),
    DateTime = lubridate::ymd_hms(paste(Date, Time))
  )

# Filter data on required dates
power_consumption <- dataset_formatted %>%
  dplyr::filter(Date >= ymd("2007-02-01") & Date <= ymd("2007-02-02"))

# Plot histogram
hist(power_consumption$Global_active_power,
     xlab = "Global Active Power (kilowatts)",
     main = "Global Active Power",
     col = "red"
)

# Export the plot as a PNG
dev.copy(png, filename = "plot1.png", width = 960, height = 960, res = 120)
# Close the plotting device
dev.off()
