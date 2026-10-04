import streamlit as st
import joblib
from pathlib import Path
import pandas as pd
from scipy.sparse import hstack

# Model paths
models_dir = Path("models")

# Load trained models
rf_model = joblib.load(models_dir / "rf_model.pkl")
encoder = joblib.load(models_dir / "encoder.pkl")
scaler = joblib.load(models_dir / "scaler.pkl")

# Features used by the model
categorical_features = [
    "AIRLINE",
    "ORIGIN_AIRPORT",
    "DESTINATION_AIRPORT"
]

numeric_features = [
    "MONTH",
    "DAY",
    "DAY_OF_WEEK",
    "SCHEDULED_DEPARTURE",
    "SCHEDULED_ARRIVAL",
    "SCHEDULED_TIME",
    "DISTANCE"
]

# Page configuration
st.set_page_config(
    page_title="Flight Delay Prediction",
    page_icon="✈️",
    layout="wide"
)

# Title
st.title("✈️ Flight Delay Prediction")
st.write(
    "Predict whether a flight is likely to arrive at least "
    "15 minutes late."
)

st.divider()

# Flight details
st.subheader("Flight Details")

col1, col2 = st.columns(2)

with col1:
    airline = st.selectbox(
        "Airline",
        [
            "AA", "AS", "DL", "UA", "WN", "B6", "F9",
            "HA", "MQ", "NK", "OO", "US", "VX", "EV"
        ]
    )

    origin_airport = st.text_input(
        "Origin Airport",
        placeholder="e.g. LAX"
    )

    destination_airport = st.text_input(
        "Destination Airport",
        placeholder="e.g. JFK"
    )

    distance = st.number_input(
        "Distance (miles)",
        min_value=1,
        max_value=10000,
        value=500
    )

with col2:
    month = st.number_input(
        "Month",
        min_value=1,
        max_value=12,
        value=1
    )

    day = st.number_input(
        "Day",
        min_value=1,
        max_value=31,
        value=1
    )

    day_of_week = st.number_input(
        "Day of Week",
        min_value=1,
        max_value=7,
        value=1
    )

    scheduled_time = st.number_input(
        "Scheduled Flight Time (minutes)",
        min_value=1,
        max_value=1000,
        value=120
    )

# Schedule
st.subheader("Schedule")

col3, col4 = st.columns(2)

with col3:
    scheduled_departure = st.number_input(
        "Scheduled Departure",
        min_value=0,
        max_value=2359,
        value=1200
    )

with col4:
    scheduled_arrival = st.number_input(
        "Scheduled Arrival",
        min_value=0,
        max_value=2359,
        value=1400
    )

st.divider()

# Prediction button
predict_button = st.button(
    "Predict Delay",
    type="primary",
    use_container_width=True
)

if predict_button:

    # Check for empty airports
    if not origin_airport or not destination_airport:

        st.warning(
            "Please enter both origin and destination airports."
        )

    else:

        origin_airport = origin_airport.upper().strip()
        destination_airport = destination_airport.upper().strip()

        # Get known airport categories
        known_origin_airports = set(
            encoder.categories_[1]
        )

        known_destination_airports = set(
            encoder.categories_[2]
        )

        # Check if origin and destination are the same
        if origin_airport == destination_airport:

            st.error(
                "Origin and destination airports cannot be the same."
            )

        # Validate origin airport
        elif origin_airport not in known_origin_airports:

            st.error(
                f"Unknown origin airport: {origin_airport}. "
                "Please enter a valid airport code."
            )

        # Validate destination airport
        elif destination_airport not in known_destination_airports:

            st.error(
                f"Unknown destination airport: {destination_airport}. "
                "Please enter a valid airport code."
            )

        else:

            # Create input dataframe
            input_data = pd.DataFrame([{
                "MONTH": month,
                "DAY": day,
                "DAY_OF_WEEK": day_of_week,
                "AIRLINE": airline,
                "ORIGIN_AIRPORT": origin_airport,
                "DESTINATION_AIRPORT": destination_airport,
                "SCHEDULED_DEPARTURE": scheduled_departure,
                "SCHEDULED_ARRIVAL": scheduled_arrival,
                "SCHEDULED_TIME": scheduled_time,
                "DISTANCE": distance
            }])

            # Encode categorical features
            encoded_data = encoder.transform(
                input_data[categorical_features]
            )

            # Scale numerical features
            scaled_data = scaler.transform(
                input_data[numeric_features]
            )

            # Combine encoded and scaled features
            final_input = hstack([
                encoded_data,
                scaled_data
            ])

            # Make prediction
            prediction = rf_model.predict(final_input)

            # Get probabilities
            probability = rf_model.predict_proba(final_input)

            delay_probability = probability[0][1]
            on_time_probability = probability[0][0]

            # Display result
            st.divider()
            st.subheader("Prediction Result")

            if delay_probability > 0.5:

                st.error(
                    "✈️ Flight predicted to be DELAYED"
                )

                st.metric(
                    "Delay Probability",
                    f"{delay_probability * 100:.2f}%"
                )

            else:

                st.success(
                    "✈️ Flight predicted to be ON TIME"
                )

                st.metric(
                    "On-Time Probability",
                    f"{on_time_probability * 100:.2f}%"
                )

            # Probability visualization
            st.write("Model Confidence")

            st.progress(delay_probability)

            col5, col6 = st.columns(2)

            with col5:
                st.metric(
                    "Delay Probability",
                    f"{delay_probability * 100:.2f}%"
                )

            with col6:
                st.metric(
                    "On-Time Probability",
                    f"{on_time_probability * 100:.2f}%"
                )