# load packages and functions
source('analysis/packages_and_functions.R', local = TRUE, chdir = FALSE)

# load petal collection data
petal = read.csv("data/raw/petal.csv")

# parse the Date column with the proper format
petal$Date = as.Date(petal$Date, "%m/%d/%Y")

# demystify site designation data values
petal <- petal %>% 
  mutate(site = case_match(site, 'A' ~ 'Mount Diablo', 'C' ~ 'SFSU greenhouse'))

# renaming 'site' to 'location'
names(petal)[names(petal) == 'site'] <- 'location'

# load porometer data
porometer_preprocess = read.csv('data/raw/porometer/porometer_preprocess.csv')

# filter out unused data columns
porometer_noise = porometer_preprocess[ , c('Time','Date','remark','Sample','Study.plot','Petal.side','gsw','E_apparent','Tref','Tleaf','leak_pct','plant')]

# renaming 'Study.plot' to 'location'
names(porometer_noise)[names(porometer_noise) == 'Study.plot'] <- 'location'

# demystify site designation data values
porometer_noise <- porometer_noise %>% 
  mutate(location = case_match(location, 'A' ~ 'Mount Diablo', 'C' ~ 'SFSU greenhouse'))

# load flower count and plant size data. Parse date columns.
flowercount = read.csv('data/raw/flowercount.csv')
flowercount$date = as.Date(flowercount$date, "%m/%d/%Y")
plantsize = read.csv('data/raw/plant_size.csv')

# load atmospheric data
atmosphere = read.csv('data/raw/T_RH/atmosphere_MtDiablo.csv')
atmosphere_gh = read.csv('data/raw/T_RH/atmosphere_greenhouse.csv')

# parse datetime columns with the proper format
atmosphere <- atmosphere %>% 
  mutate(Time = parse_date_time(Time, 
                                orders = c("ymd_HMS")))

# parse datetime columns with the proper format
atmosphere_gh <- atmosphere_gh %>% 
  mutate(Datetime_PST = parse_date_time(Datetime_PST, 
                                        orders = c("ymd_HMS")))

# parse datetime columns with the proper format
atmosphere_gh <- atmosphere_gh %>% 
  mutate(Datetime_PDT = parse_date_time(Datetime_PDT, 
                                        orders = c("ymd_HMS")))

# parse datetime columns with the proper format
atmosphere$Date = as_date(atmosphere$Time)
atmosphere$HMS = hms::as_hms(atmosphere$Time)
atmosphere_gh$Date = as_date(atmosphere_gh$Datetime_PST)
atmosphere_gh$Date_PDT = as_date(atmosphere_gh$Datetime_PDT)
atmosphere_gh$Time_PDT = hms::as_hms(atmosphere_gh$Time_PDT)

# load PRISM data and parse date column
prism = read.csv('data/raw/T_RH/PRISM.csv')
prism$Date = as.Date(prism$Date, "%m/%d/%Y")

# calculate measures of floral physiology
petal = petal %>% mutate(p_projectedArea = p_surfaceArea)
petal = petal %>% mutate(p_surfaceArea = 2*p_surfaceArea)
petal = petal %>% mutate(p_succulence = (p_freshMass - p_dryMass) / p_projectedArea)
petal = petal %>% mutate(p_waterContentPerDryMass = (p_freshMass - p_dryMass) / p_dryMass)
petal = petal %>% mutate(p_waterMass = (p_freshMass - p_dryMass))
petal = petal %>% mutate(p_tissueMassArea = p_dryMass/p_projectedArea)

# remove leaf data from petal
# (note to self: bring back leaf.csv?)

# make week_of_flowering for Mount Diablo NULL

# rename rep to Sample

# rename columns for export

# export to data/processes/petal.csv

# filtering the petal dataframe by site
petal_gh = filter(petal,location=='SFSU greenhouse')
petal_MtDiablo = filter(petal,location=='Mount Diablo')

# calculating VPD
atmosphere$VPD = vpd(atmosphere$Humidity..rh.,atmosphere$Celsius.C.)
atmosphere_gh$VPD = vpd(atmosphere_gh$Humidity..rh.,atmosphere_gh$Celsius.C.)