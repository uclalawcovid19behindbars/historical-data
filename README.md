
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Historical Data

## Background

The [UCLA Law COVID-19 Behind Bars Data
Project](https://uclacovidbehindbars.org/), launched in March 2020,
tracks the spread and impact of COVID-19 in American carceral facilities
and advocates for greater transparency and accountability around the
pandemic response of the carceral system. Since March, we have been
collecting and reporting facility-level data on COVID-19 in prisons,
jails, and other correctional centers.

## Prison and jail data overview

We primarily collect data from federal, state, and local correctional
agency websites using web scraping programs we developed to
automatically collect reported data three to four times per week. Our
newly scraped data, updated 3-4 times a week, is available in our [data
repository](https://github.com/uclalawcovid19behindbars/data). For
details on the specific code we use for scraping data, please visit our
[scraper
repository](https://github.com/uclalawcovid19behindbars/covid19_behind_bars_scrapers).

Our core data of interest include:

-   the cumulative number of infections among incarcerated people and
    staff,
-   the cumulative number of deaths among incarcerated people and staff,
-   and the cumulative number of tests among incarcerated people and
    staff.

However, correctional authorities vary in what they report publicly. For
example, as of December 2020, the Pennsylvania Department of Corrections
reports data for all six of these core variables, while the Mississippi
Department of Corrections reports data for only one.

Further, we aim to collect and report Covid-19 facility-level data,
where possible, from all federal, state, and county correctional
agencies across the country. In general, the Federal Bureau of Prisons
reports its Covid-19 prison data by facility. However, not all state and
county jurisdictions report data disaggregated by facility for all
variables. Please visit our [website](https://uclacovidbehindbars.org/)
for more info on data availability.

When data are not available publicly, we make every effort to obtain
missing information through original public records requests. In some
cases, we also partner with other organizations who gather data directly
from agencies. Our data for several jails in California is collected by
[Davis Vanguard](https://www.davisvanguard.org/), who have been
generously sharing their COVID-19 data with us. Our data for state
prisons in Massachusetts is reported by [the ACLU of
Massachusetts](https://data.aclum.org/sjc-12926-tracker/). If you would
like to contribute data on COVID-19 in a facility that we don’t
currently include, please see [our
template](https://docs.google.com/spreadsheets/d/1cqjCvbXuUh5aIQeJ4NRKdUwVAb4adaWTK-nBPFAj0og/edit#gid=363817589).
We always welcome additional contributors!

## Historical Data Availability

We are in the process of cleaning historical data going back to the
beginning of the pandemic. Currently, the states with historical data
available are:

    > 01) Alabama
    > 02) Alaska
    > 03) Arizona
    > 04) Arkansas
    > 05) California
    > 06) Colorado
    > 07) Connecticut
    > 08) Delaware
    > 09) Florida
    > 10) Georgia
    > 11) Hawaii
    > 12) Illinois
    > 13) Indiana
    > 14) Iowa
    > 15) Kansas
    > 16) Kentucky
    > 17) Louisiana
    > 18) Maine
    > 19) Maryland
    > 20) Massachusetts
    > 21) Michigan
    > 22) Minnesota
    > 23) Mississippi
    > 24) Missouri
    > 25) Montana
    > 26) Nebraska
    > 27) Nevada
    > 28) New Hampshire
    > 29) New Jersey
    > 30) New Mexico
    > 31) North Carolina
    > 32) North Dakota
    > 33) Oregon
    > 34) Pennsylvania
    > 35) South Carolina
    > 36) South Dakota
    > 37) Tennessee
    > 38) Texas
    > 39) Utah
    > 40) Vermont
    > 41) Virginia
    > 42) Washington
    > 43) West Virginia
    > 44) Wisconsin
    > 45) Wyoming

We aim to have all states’ data cleaned by early summer 2021.

## Access

Instructions for accessing our historical time-series data are provided
in our [main data
repository](https://github.com/uclalawcovid19behindbars/data#accessing-time-series-data).

## Data dictionary

| Variable               | Description                                                                                                                                                    |
|------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `Facility.ID`          | Integer ID that uniquely identifies every facility                                                                                                             |
| `Jurisdiction`         | Whether the facility falls under `state`, `county`, `federal`, or `immigration` jurisdiction                                                                   |
| `State`                | State where the facility is located                                                                                                                            |
| `Name`                 | Facility name                                                                                                                                                  |
| `Date`                 | Date data was scraped (not necessarily date updated by the reporting source)                                                                                   |
| `source`               | Source from which the data was scraped                                                                                                                         |
| `Residents.Confirmed`  | Cumulative number of incarcerated individuals infected with COVID-19                                                                                           |
| `Staff.Confirmed`      | Cumulative number of staff infected with COVID-19                                                                                                              |
| `Residents.Deaths`     | Cumulative number of incarcerated individuals who died from COVID-19                                                                                           |
| `Staff.Deaths`         | Cumulative number of staff who died from COVID-19                                                                                                              |
| `Residents.Recovered`  | Cumulative number of incarcerated individuals who recovered from COVID-19                                                                                      |
| `Staff.Recovered`      | Cumulative number of staff who recovered from COVID-19                                                                                                         |
| `Residents.Tadmin`     | Cumulative number of incarcerated individuals tested for COVID-19                                                                                              |
| `Staff.Tested`         | Cumulative number of staff tested for COVID-19                                                                                                                 |
| `Residents.Negative`   | Cumulative number of incarcerated individuals who tested negative for COVID-19                                                                                 |
| `Staff.Negative`       | Cumulative number of staff who tested negative for COVID-19                                                                                                    |
| `Residents.Pending`    | Cumulative number of incarcerated individuals with pending test results for COVID-19                                                                           |
| `Staff.Pending`        | Cumulative number of staff with pending test results for COVID-19                                                                                              |
| `Residents.Quarantine` | Cumulative number of incarcerated individuals in quarantine from COVID-19                                                                                      |
| `Staff.Quarantine`     | Cumulative number of staff in quarantine from COVID-19                                                                                                         |
| `Residents.Active`     | Non-cumulative number of incarcerated individuals infected with COVID-19                                                                                       |
| `Population.Feb20`     | Population of the facility as close to February 1, 2020 as possible. Source listed in `Source.Population.Feb20`                                                |
| `Residents.Population` | Up-to-date population of incarcerated individuals reported by DOC website or public records.                                                                   |
| `Residents.Tested`     | Ambiguous metric of incarcerated individuals tested for COVID-19                                                                                               |
| `Residents.Initiated`  | Cumulative number of incarcerated individuals who have initiated COVID-19 vaccination (i.e. received any dosage of a vaccine).                                 |
| `Residents.Completed`  | Cumulative number of incarcerated individuals who have fully completed their COVID-19 vaccination schedule                                                     |
| `Residents.Vadmin`     | Cumulative number of COVID-19 vaccines administered to incarcerated individuals                                                                                |
| `Staff.Initiated`      | Cumulative number of staff who have initiated COVID-19 vaccination (i.e. received any dosage of a vaccine).                                                    |
| `Staff.Completed`      | Cumulative number of staff who have fully completed their COVID-19 vaccination schedule                                                                        |
| `Staff.Vadmin`         | Cumulative number of COVID-19 vaccines administered to staff                                                                                                   |
| `HIFLD.ID`             | The facility’s corresponding [Homeland Infrastructure Foundation-Level Data](https://hifld-geoplatform.opendata.arcgis.com/datasets/prison-boundaries/data) ID |

Additional geographic fields: `Address`, `Zipcode`, `City`, `County`,
`Latitude`, `Longitude`, `County.FIPS`.

For more information on facility descriptors such as `Description`,
`Security`, `Different.Operator`, etc, please visit our [facility data
repository](https://github.com/uclalawcovid19behindbars/facility_data).

## Citations

Citations for academic publications and research reports:

    Sharon Dolovich, Aaron Littman, Kalind Parish, Grace DiLaura, Chase Hommeyer,  Michael Everett, Hope Johnson, Neal Marquez, and Erika Tykagi. UCLA Law Covid-19 Behind Bars Data Project: Jail/Prison Confirmed Cases Dataset [date you downloaded the data]. UCLA Law, 2020, https://uclacovidbehindbars.org/.

Citations for media outlets, policy briefs, and online resources:

    UCLA Law Covid-19 Behind Bars Data Project, https://uclacovidbehindbars.org/.

## Data licensing

Our data is licensed under a [Creative Commons
Attribution-NonCommercial-ShareAlike 4.0 International
License](https://creativecommons.org/licenses/by-nc-sa/4.0/). That means
that you must give appropriate credit, provide a link to the license,
and indicate if changes were made. You may not use our work for
commercial purposes, which means anything primarily intended for or
directed toward commercial advantage or monetary compensation.
