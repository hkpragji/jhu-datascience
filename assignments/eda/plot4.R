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

# Create function to format x-axis with days of the week
create_day_axis <- function(dataset) {
  # Get unique days of the week
  unique_days <- unique(dataset$Date)
  # Include the (n+1)th day on the x-axis
  extended_days <- c(unique_days, max(unique_days) + 1)
  # Reformat x-axis tick labels to show day of week
  axis.POSIXct(1, at = extended_days, format = "%a")
}

# Open the PNG device
png(filename = "plot4.png", width = 960, height = 960, res = 120)
# Create a 2x2 plotting matrix
par(mfrow = c(2, 2))

# Begin creating plots from left to right

# Plot 1
plot(
  x = power_consumption$DateTime,
  y = power_consumption$Global_active_power,
  type = "l",
  xaxt = "n",
  xlab = "Day",
  ylab = "Global Active Power (kilowatts)"
)
create_day_axis(power_consumption)

# Plot 2
plot(
  x = power_consumption$DateTime,
  y = power_consumption$Voltage,
  type = "l",
  xaxt = "n",
  xlab = "Day",
  ylab = "Voltage"
)
create_day_axis(power_consumption)

# Plot 3
plot(
  x = power_consumption$DateTime,
  y = power_consumption$Sub_metering_1,
  type = "l",
  xaxt = "n",
  xlab = "Day",
  ylab = "Energy sub metering"
)
create_day_axis(power_consumption)
# Create legend
lines(power_consumption$DateTime, power_consumption$Sub_metering_2, col = "red")
lines(power_consumption$DateTime, power_consumption$Sub_metering_3, col = "blue")
legend(
  x = "topright", # or "topleft"
  col = c("black", "red", "blue"),
  lty = 1,
  lwd = 2,
  cex = 0.65,
  # inset = c(-0.005, 0),
  legend = c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3")
)

# Plot 4
plot(
  x = power_consumption$DateTime,
  y = power_consumption$Global_reactive_power,
  type = "l",
  xaxt = "n",
  xlab = "Day",
  ylab = "Global Reactive Power"
)
create_day_axis(power_consumption)

# Close the plotting device
dev.off()
