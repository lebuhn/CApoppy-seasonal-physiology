# CApoppy-seasonal-physiology

## Overview

This repository investigates seasonal variation in floral morphology and physiology within a single population of California poppy (*Eschscholzia californica*) at Mount Diablo State Park, California.

The project builds on the research and datasets developed by **Shea Nolan** as part of a [master's thesis](https://snolan419.github.io/eschscholzia-flowers/shrinking-flowers.html). The original research includes measurements of petal morphology, flower physiology, site microclimate, and flowering patterns across the season.

## Project origins and acknowledgment

This repository was created from Shea Nolan's original GitHub repository, [snolan419/eschscholzia-flowers](https://github.com/snolan419/eschscholzia-flowers).

The original repository contains petal measurements, site microclimate data, porometer readings, scanned petal images, flower counts, Python preprocessing scripts, and R analysis scripts. These materials provide the foundation for the present project.

**Credit for the original study, data collection, and associated research materials belongs to Shea Nolan.**

## Current project

The purpose of this repository is to develop and document analyses of seasonal variation in California poppy floral traits, building on the original datasets and analyses.

The repository will be developed to support reproducible data processing, statistical analyses, and visualization of seasonal patterns in floral morphology and physiology.

As the project develops, this README will document modifications to the original datasets, analytical methods, and scripts, distinguishing the original research from subsequent analyses.

## Data and code organization

The repository initially retains the structure and materials of the original project:

- `data/` — Original datasets and Python preprocessing scripts
- `analysis/` — R scripts for statistical analyses
- `figures/` — Generated figures

Changes to the repository structure and analytical workflows will be documented as the project develops.

## Original research

Nolan, Shea. Master's thesis investigating flower physiology in *Eschscholzia californica* at Mount Diablo State Park.

- [Original research and thesis](https://snolan419.github.io/eschscholzia-flowers/shrinking-flowers.html)
- [Original GitHub repository](https://github.com/snolan419/eschscholzia-flowers)

Please consult the original repository for information about the source datasets and original analytical methods.

## Languages

American English (en-US).

## Data Fields

### petal.csv

*A data table that contains petal measurements for California poppies. Each row corresponds to a petal collected from an individual plant.*

**Date** – calendar date.
Samples were collected between 10am and 2pm.

**week** – corresponding week number in the fieldwork calendar.
Week 1 begins on 2/25/2025

**site** – site designation.
A corresponds to Mount Diablo State Park, C corresponds to the SFSU greenhouse.
B was an unused designation that was co-opted for porometer calibration.

**rep** – replicate number.
Resets each week, corresponds to the number of samples.

**plant** – plant designation.
Petal collection plants were defined as #21 - #40.
Since petal collections were non-repeat measurements, unique plants were sampled haphazardly each week.
Therefore the number designation only reflects the order in which they were sampled.
These were used alongside date as a foreign key to porometer.csv

**p_fresh_mass** – petal fresh mass in milligrams.
This measurement is taken at the plant physiology lab upon return from the field site, however on week 1 the sample was measured on 2/27/2025, two days after collection.
Samples were kept in plastic bags with a damp paper towel, and they were refrigerated if necessary to delay measurement.

**p_surface_area** – This is actually petal projected area in cm3.
Measured by scanning the petals and analyzing them in ImageJ using the make binary and analyze particles tools.

**p_dry_mass** – petal dry mass in milligrams.
Petals were dried in an oven at 70 degrees C for 48 - 72 hours.

**l_fresh_mass** – leaf fresh mass in milligrams.
Leaves were proximate to the sampled flower.
Only measured on 3/18/2025

**l_surface_area** – leaf projected area in cm3.
Only measured on 3/18/2025

**l_dry_mass** – leaf dry mass in milligrams.
Only measured on 3/18/2025

**week_of_flowering** – depends on site designation.
For Mount Diablo, this is a duplicate of the week column.
For SFSU greenhouse, this refers to plant ontogeny, with week 1 defined as the first week an individual was observed producing flowers.

### flowercount.csv

*A data table that contains flower counts for flagged plants at Mount Diablo. Each row corresponds to an individual plant observed on a given day.*

**date** – see 'Date' in petal.csv

**week** – see 'week' in petal.csv

**site** – see 'site' in petal.csv

**rep** – replicate number, corresponds to the number of flagged plants.
In flowercount.csv, this matches plant designation.

**plant** – plant designation.
Flower count plants are defined as #1 - #20.
Since flower counts were repeat measurements, these designations carried over each week.
The flower counts of a given designation (e.g. #1) reflect the number of flowers that individual produced throughout the season.
These may be used alongside date as a foreign key to porometer.csv

**flower_count** – number of flowers on the plant.

**deadOrAlive** – qualitative observation that describes whether the above-ground plant tissue was missing or senesced.
1 indicates that the plant was still producing green stems, green leaves, or flowers.
0 indicates the above ground tissue was destroyed or appeared dried and brown.

### plant_size.csv

*A data table that contains plant radius measurements for flagged plants at Mount Diablo. Each row corresponds to an individual plant.*

**rep** – replicate number, corresponds to the number of flagged plants.
In plant_size.csv, this is intended to be a foreign key to flowercount.csv

**radius_ft** – the radius of the flagged plant in feet.

**radius_m** – the radius of the flagged plant in meters.

### atmosphere_MtDiablo.csv

*A data table that contains microclimate measurements taken every 30 minutes at Mount Diablo. Each row corresponds to a temperature and relative humidity reading captured at a single moment in time.*

**Time** – a date and timestamp.
The EZ log sensor clock was set by my laptop during each data retrieval, so the time zone is Pacific Standard Time and Pacific Daylight Time.
PDT was delayed because the EZ log sensor didn't update until data retrieval.
This discrepancy was addressed in the analysis.

**daynight** – for Mount Diablo data, this was defined by a custom Python script that identified whether a timestamp at a specified location was before or after sunrise and sunset for a given day.
Each observation is either 'day' or 'night,' and as time passes there are more day observations relative to night as daylength increases.

**Celsius(C)** – temperature, measured in degrees Celsius.
**Humidity(%)** – relative humidity, measured as percent.

**Dew Point(C)** – dew point, measured in degrees Celsius.
**Comments** – usually blank, but for Mount Diablo data I included some observations that are labeled 'Vaisala hand-held.' These were single data points measured with a hand-held temperature and humidity probe during weeks when sensor data was missing.

**Serial Number** – The unique code associated with each EZ log sensor.
This is usually blank, but the number appears in the first observation of each data retrieval.
It may be used as an indicator for when the technician arrived in the field for a petal collection day.

### atmosphere_greenhouse.csv

*A data table that contains microclimate measurements taken every 30 minutes at SFSU greenhouse bay 7. Each row corresponds to a temperature and relative humidity reading captured at a single moment in time.*

**Time** – a date and timestamp.
The EZ log sensor clock was set by my laptop during each data retrieval, so the time zone is Pacific Standard Time and Pacific Daylight Time.
PDT was delayed because the EZ log sensor didn't update until data retrieval.
This discrepancy was addressed in the preprocessing script.

**daynight** – for greenhouse data, daytime and nighttime was defined by the setpoints when temperatures changed in the greenhouse: 6:30am for the beginning of the day and 9:00pm for the end of the day.
I used temperature to define day and night because I had actually made a mistake with the lighting in the greenhouse: the time when the lights turned on was getting earlier and earlier over time.
The plants always received at least 15 hours of lighting, but before I noticed this (around the end of daylight savings) they were getting around 17 hours of overhead lighting.
Since I didn't know exactly when the lights were turning on, I used temperature to define day and night.

**Celsius(C)** – temperature, measured in degrees Celsius.
**Humidity(%)** – relative humidity, measured as percent.

**Dew Point(C)** – dew point, measured in degrees Celsius.
**Comments** – usually blank, but for Mount Diablo data I included some observations that are labeled 'Vaisala hand-held.' These were single data points measured with a hand-held temperature and humidity probe during weeks when sensor data was missing.

**Serial Number** – The unique code associated with each EZ log sensor.
This is usually blank, but the number appears in the first observation of each data retrieval.
It may be used as an indicator for when the technician arrived in the field for a petal collection day.

### porometer_preprocess.csv

*Includes full readouts from the LI-600 porometer. Most data columns were unused, but some relevant columns are described. Each row corresponds to a porometer measurement of a petal. Petals were measured twice, once on the top (adaxial) and once on the bottom (abaxial).*

**Time** - timestamp in Pacific Standard Time.
Porometer clock was not changed for Daylight Savings.

**Date** - calendar date, also in Pacific Standard Time.

**Study plot** - site designation.
A corresponds to Mount Diablo State Park, C corresponds to the SFSU greenhouse.
B was an unused designation that was co-opted for porometer calibration.

**Petal side** - indicates the whether the measurement was taken on the adaxial or abaxial side of the flower petal.

**gsw** - petal surface conductance, measured in moles per meter squared per second.

**leak_pct** - leak percent indicated whether a porometer measurement had a proper seal.
Values greater than 5% were removed.

**plant** - plant designation.
Flower count plants are defined as #1 - #20.
Since flower counts were repeat measurements, these designations carried over each week.
The flower counts of a given designation (e.g. #1) reflect the number of flowers that individual produced throughout the season.
Petal collection plants were defined as #21 - #40.
Since petal collections were non-repeat measurements, unique plants were sampled haphazardly each week.
Therefore the number designation only reflects the order in which they were sampled.
This data column was used alongside date as a foreign key to petal.csv, and may also be used as a foreign key to flowercount.csv

**remark** - Three flowers per plant were measured in greenhouse plants, so this data field was used to distinguish flower measurements (Flower 1, Flower 2, Flower 3).
Petals were always collected from Flower 1 for projected area and water content measurement.
Since only 1 flower was measured per plant at Mount Diablo, this data field was unused.
