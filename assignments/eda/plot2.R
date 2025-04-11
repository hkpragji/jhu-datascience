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

# Plot line chart of global active power usage
plot(
  x = power_consumption$DateTime,
  y = power_consumption$Global_active_power,
  type = "l",
  xaxt = "n",
  xlab = "Day",
  ylab = "Global Active Power (kilowatts)"
)

# Get unique days of the week
unique_days <- unique(power_consumption$Date)
# Include the (n+1)th day on the x-axis
extended_days <- c(unique_days, max(unique_days) + 1)
# Reformat x-axis tick labels to show day of week
axis.POSIXct(1, at = extended_days, format = "%a")

# Export the plot as a PNG
dev.copy(png, filename = "plot2.png", width = 960, height = 960, res = 120)
# Close the plotting device
dev.off()
