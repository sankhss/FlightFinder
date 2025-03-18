# FlightFinder

A SwiftUI app for searching flights with real-time availability.

## Architecture

FlightFinder follows the **MVVM (Model-View-ViewModel)** architecture:
- **Model**: Defines the data structure for flights and stations.
- **ViewModel**: Handles business logic, state management, and API calls.
- **View**: SwiftUI views that display UI and bind to the ViewModel.
- **Network Layer**: Manages API requests.
- **Service Layer**: Handles data retrieval for flights and stations.

## Features

✅ Flight search with real-time data  
✅ Station selection with search  
✅ Date picker for departure  
✅ Passenger selection (adults, teens, children)  

## API Endpoints

### Flight Search
- **URL:** `https://nativeapps.ryanair.com/api/v4/Availability`
- **Example Request:**
  ```json
  {
    "origin": "DUB",
    "destination": "STN",
    "dateout": "2022-08-09",
    "adt": 1,
    "teen": 0,
    "chd": 0
  }
  ```

### Stations List
- **URL:** `https://mobile-testassets-dev.s3.eu-west-1.amazonaws.com/stations.json`

## Testing

The app includes **unit tests, integration tests, and end-to-end tests** using XCTest:
- **ViewModel Tests:** Ensures correct state updates and API calls.
- **Service Tests:** Validates flight and station retrieval.
- **Network Tests:** Tests the API client with mocked responses.
- **End-to-End Tests:** Calls real APIs to validate the complete flow.
