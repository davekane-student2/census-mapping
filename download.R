library(tidycensus)
library(dplyr)
library(sf)

options(tigris_use_cache = TRUE)

# Get a free key at https://api.census.gov/data/key_signup.html, then run:
# tidycensus::census_api_key("YOUR KEY", install = TRUE)
under_18_variables <- c(
  "B01001_003", "B01001_004", "B01001_005", "B01001_006",
  "B01001_027", "B01001_028", "B01001_029", "B01001_030"
)

age_variables <- c("B01001_001", under_18_variables)

age_data <- get_acs(
  geography = "tract",
  state = "FL",
  county = "Sarasota",
  year = 2024,
  survey = "acs5",
  variables = age_variables,
  geometry = TRUE,
  output = "wide"
)

sarasota_tracts <- age_data |>
  mutate(
    total_population = B01001_001E,
    population_under_18 = rowSums(
      across(all_of(paste0(under_18_variables, "E"))),
      na.rm = TRUE
    ),
    percent_under_18 = 100 * population_under_18 / total_population
  ) |>
  select(GEOID, NAME, total_population, population_under_18, percent_under_18, geometry)

write.csv(
  st_drop_geometry(sarasota_tracts),
  "county/sarasota_tracts_under18_2024.csv",
  row.names = FALSE
)

st_write(
  sarasota_tracts,
  "county/sarasota_tracts_under18_2024.geojson",
  delete_dsn = TRUE,
  quiet = TRUE
)

# 2. State of Florida (all census tracts in FL)
fl_age_data <- get_acs(
  geography = "tract",
  state = "FL",
  year = 2024,
  survey = "acs5",
  variables = age_variables,
  geometry = TRUE,
  output = "wide"
)

florida_tracts <- fl_age_data |>
  mutate(
    total_population = B01001_001E,
    population_under_18 = rowSums(
      across(all_of(paste0(under_18_variables, "E"))),
      na.rm = TRUE
    ),
    percent_under_18 = 100 * population_under_18 / total_population
  ) |>
  select(GEOID, NAME, total_population, population_under_18, percent_under_18, geometry)

write.csv(
  st_drop_geometry(florida_tracts),
  "state/florida_tracts_under18_2024.csv",
  row.names = FALSE
)

st_write(
  florida_tracts,
  "state/florida_tracts_under18_2024.geojson",
  delete_dsn = TRUE,
  quiet = TRUE
)

# 3. Whole US (all census tracts across 50 states + DC)
us_age_data <- get_acs(
  geography = "tract",
  state = c(state.abb, "DC"),
  year = 2024,
  survey = "acs5",
  variables = age_variables,
  geometry = TRUE,
  output = "wide"
)

us_tracts <- us_age_data |>
  mutate(
    total_population = B01001_001E,
    population_under_18 = rowSums(
      across(all_of(paste0(under_18_variables, "E"))),
      na.rm = TRUE
    ),
    percent_under_18 = 100 * population_under_18 / total_population
  ) |>
  select(GEOID, NAME, total_population, population_under_18, percent_under_18, geometry)

write.csv(
  st_drop_geometry(us_tracts),
  "country/us_tracts_under18_2024.csv",
  row.names = FALSE
)

st_write(
  us_tracts,
  "country/us_tracts_under18_2024.geojson",
  delete_dsn = TRUE,
  quiet = TRUE
)
