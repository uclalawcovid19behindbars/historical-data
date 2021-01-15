# historical-data

## Background

The UCLA Law Covid-19 Behind Bars Data Project, launched in March 2020, tracks the spread and impact of Covid-19 in American carceral facilities and pushes for greater transparency and accountability around the pandemic response of the carceral system. For more information on the organization as a whole, see our website at: http://uclacovid19behindbars.org/.

Since the beginning of the Covid-19 pandemic, the public’s ability to assess the extent and impact of the spread of the virus has been limited by shortcomings in data reporting in the United States. This is particularly true, and presents especially severe consequences, for data concerning Covid-19 in U.S. prisons, jails, immigration detention centers, and other carceral settings that confine over two million individuals. The overcrowding and subpar healthcare systems in carceral facilities make them hotspots for viral spread, and the people who work and are incarcerated in these facilities do not have the option to socially distance. Epidemiological data reporting in these settings are limited, often vaguely-defined, and generally not comparable between jurisdictions. To save lives, advocates and organizers need data to demonstrate the urgency of this public health crisis, and ultimately to push for the release of enough incarcerated people to limit the spread. 

In an effort to make publicly accessible the limited data that correctional agencies report, the UCLA Law Covid-19 Behind Bars Data Project collects and centralizes data on Covid-19 infections and deaths for incarcerated persons and staff within U.S. carceral facilities. The project also collects and centralizes other carceral data, like incarcerated population numbers, which are critical to contextualizing Covid-19 infection numbers and which do not exist elsewhere in a unified dataset. Our methods for collecting and reporting data on prisons and jails differ from those used for data on immigration and youth facilities; these methods are explained separately below. 

## Prison and jail data overview

We primarily collect data from federal, state, and local correctional agency websites using web scraping programs we developed to automatically collect reported data three to four times per week. Our newly scraped data, updated 3-4 times a week, is available in our [data repository](https://github.com/uclalawcovid19behindbars/data/blob/master/Adult%20Facility%20Counts/adult_facility_covid_counts_today_latest.csv). For details on the specific code we use for scraping data, please visit our [scraper repository](https://github.com/uclalawcovid19behindbars/covid19_behind_bars_scrapers).

Our core data of interest include:

* the cumulative number of infections among incarcerated people and staff,
* the cumulative number of deaths among incarcerated people and staff,
* and the cumulative number of tests among incarcerated people and staff. 

However, correctional authorities vary in what they report publicly. For example, as of December 2020, the Pennsylvania Department of Corrections reports data for all six of these core variables, while the Mississippi Department of Corrections reports data for only one. 

Further, we aim to collect and report Covid-19 facility-level data, where possible, from all federal, state, and county correctional agencies across the country. In general, the Federal Bureau of Prisons reports its Covid-19 prison data by facility. However, not all state and county jurisdictions report data disaggregated by facility for all variables. We are working on a detailed table of variable availability by jurisdiction. In the meantime, please consult the individual state pages to see where we have facility-level data. 

When data are not available publicly, we make every effort to obtain missing information through original public records requests. In some cases, we also partner with other organizations who gather data directly from agencies. We compile our data into a spreadsheet we maintain on GitHub. We also maintain a historical dataset that includes all data we’ve collected since the start of the pandemic. We are currently working to clean the reporting inconsistencies in that data to enable us to display time series visualizations. 

## Data dictionary

| Variable               | Description                                                                                                                                                    |
| ---------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
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
| `Residents.Tested`     | Ambiguous metric of incarcerated individuals tested for COVID-19                                                                                               |
| `Residents.Population` | Daily population of incarcerated individuals reported by DOC website                                                                                           |
| `Population.Feb20`     | Population of the facility as close to February 1, 2020 as possible. Source listed in `Source.Population.Feb20`                                                |
| `Capacity`             | Carceral capacity, as reported by the source listed in `Source.Capacity`.                                                                                      |
| `HIFLD.ID`             | The facility’s corresponding [Homeland Infrastructure Foundation-Level Data](https://hifld-geoplatform.opendata.arcgis.com/datasets/prison-boundaries/data) ID |


Additional geographic fields: `Address`, `Zipcode`, `City`, `County`, `Latitude`, `Longitude`, `County.FIPS`.

## Citations 

Citations for academic publications and research reports:

    Sharon Dolovich, Aaron Littman, Kalind Parish, Grace DiLaura, Chase Hommeyer,  Michael Everett, Hope Johnson, Neal Marquez, and Erika Tykagi. UCLA Law Covid-19 Behind Bars Data Project: Jail/Prison Confirmed Cases Dataset [date you downloaded the data]. UCLA Law, 2020, https://uclacovidbehindbars.org/.
 
Citations for media outlets, policy briefs, and online resources:

    UCLA Law Covid-19 Behind Bars Data Project, https://uclacovidbehindbars.org/.

## Data licensing

Our data is licensed under a [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-nc-sa/4.0/). That means that you must give appropriate credit, provide a link to the license, and indicate if changes were made. You may not use our work for commercial purposes, which means anything primarily intended for or directed toward commercial advantage or monetary compensation. 

----------

## Florida Notes
- Population data not yet present (as of posting on December 3rd 2020). Except to have this in within the next few weeks.
- Removed two observations of "GEO" prison that had no data associated with them. 

## North Carolina Notes
- Population data not yet present (as of posting in December 2020). Not sure yet when this will become available. 

The following facilities seem to be reporting active cases rather than cumulative cases in the column `Residents.Confirmed`:
* Wilkes CC 
* Marion CI 
* Foothills CI 
* Central Prison 
* Alexander CI 

Because the facilities did not provide any specification, we're leaving the counts as-scraped. 

## Wisconsin Notes
- Population data source was compiled by weekly reports, available here: https://doc.wi.gov/Pages/DataResearch/DataAndReports.aspx 
- Removed youth facilities for now. Will add these back in by January 2021.
