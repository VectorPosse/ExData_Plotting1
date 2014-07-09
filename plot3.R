###################################
## Load, subset, and clean data: ##
###################################


## Read in data as a data table (using fread for speed).
## This also converts "?" to NA.
library(data.table)
power <- fread("household_power_consumption.txt", 
    colClasses = "character", na.strings = c("?") )

## We're only interested in February 1, 2007 and February 2, 2007.
power <- subset(power, (Date == "1/2/2007" | Date == "2/2/2007"))

## Convert all columns except Date and Time to numeric.
## (This also throws away Date and Time, so we have to save those
## two columns, modify power, and then cbind them back.)
powerDateTime <- copy(power[,1:2, with=FALSE])
power <- power[, lapply(.SD, as.numeric), .SDcols = 3:9]
power <- cbind(powerDateTime, power)
rm(powerDateTime)

## Create DateTime column to concatenate a single date/time object.
power <- power[, DateTime := paste(Date, Time, sep = " ")]

## Data tables do not support POSIXlt objects, so we have to convert to 
## data frame to use strptime.
power <- data.frame(power)
power$DateTime <- strptime(power$DateTime, format = "%d/%m/%Y %H:%M:%S")

## Drop original Date and Time columns now that we have DateTime
power <- subset(power, select = -c(Date, Time))


###################################
## Make and save plot:           ##
###################################


png("plot3.png", width = 480, height = 480)
with(power, {
    plot(DateTime, Sub_metering_1,
        xlab = "", ylab = "Energy sub metering", type = "l")
    lines(DateTime, Sub_metering_2, col = "red")
    lines(DateTime, Sub_metering_3, col = "blue")
    }
)
legend("topright", lty = 1, col = c("black", "blue", "red"),
    legend = c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"))
dev.off()