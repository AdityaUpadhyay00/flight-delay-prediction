# Flight Delay Prediction and Airport Operational Analytics

## Overview

An end-to-end data science project that analyzes flight operations and predicts whether a flight will arrive at least 15 minutes late.

The project combines **Python, Machine Learning, PostgreSQL, SQL, Tableau, and Streamlit** to build a complete analytics and prediction system.

## Project Objectives

- Analyze flight delay and cancellation patterns.
- Identify airlines, airports, routes, and periods with higher delay rates.
- Analyze major causes of flight delays.
- Build a machine learning model to predict flight delays.
- Develop an interactive dashboard for operational analytics.
- Build a Streamlit interface for real-time flight delay prediction.

## Tech Stack

- **Python**
- **Pandas & NumPy**
- **Scikit-learn**
- **SciPy**
- **PostgreSQL**
- **SQL**
- **Tableau**
- **Streamlit**
- **Jupyter Notebook**
- **Joblib**

## Dataset

The project uses the **2015 US Flight Delays and Cancellations** dataset.

The dataset contains information about:

- Airlines
- Origin and destination airports
- Scheduled flight times
- Flight distance
- Arrival and departure delays
- Cancellations
- Cancellation reasons
- Delay causes

The PostgreSQL database contains approximately **5.8 million flight records**.

## Machine Learning

### Target

A flight is classified as delayed when:

```text
Arrival Delay >= 15 minutes