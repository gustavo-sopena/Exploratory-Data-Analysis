# Exploratory Data Analysis

This repository contains the folders:

- COVID-19
- Nashville
- Pizza

The projects for COVID-19 and Nashville were written following a guide set up by Alex The Analyst.
The Pizza project was inspired by a guide created by Adam Finer.

The queries were executed against a local server under MySQL, version 5.4.

## Projects

### COVID-19

In this project, a dataset of COVID-19 deaths and vaccinations is explored.
The databases constructed is called `COVID`.
This file contains the tables `CovidDeaths` and `CovidVaccinations`.
The tables were made from the files `covid-vaccinations.csv` and `covid-deaths.csv`, respectively.

### Nashville

In this project, a dataset of Nashville Housing data is modified in order to clean up the data.
The database constructed is called `Housing`.
This file contains the table `Nashville`.
The table was made from the file `housing-nashville-data.csv`.

### Pizza

In this project, data is explored from a fictitious pizzeria.
A database for all important information is designed and data is visualized in a dashboard.

This exploration project uses data aggregated from various data sets obtained from Kaggle:

- [Maven Pizza Challenge Dataset](https://www.kaggle.com/datasets/neethimohan/maven-pizza-challenge-dataset): used to obtain the required fields such as orders, customer_id, item_name, item_size, and item_price
- [Common Tree Species](https://www.kaggle.com/datasets/donnetew/common-tree-species-us-forests): used to generate dummy street addresses for customers
- [Human Resources Data Set](https://www.kaggle.com/datasets/davidepolizzi/hr-data-set-based-on-human-resources-data-set?select=HR+DATA.txt): used to generate a list of customers

[The dashboard for this project is available in the associated write-up.](https://gustavo-sopena.github.io/projects/Pizza-Data-Study)
