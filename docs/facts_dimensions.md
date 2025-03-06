# Technical Documentation: Facts and Dimensions

## Introduction

In data warehousing, organizing and analyzing large volumes of data effectively is crucial for gaining insights and making informed decisions. To achieve this, we use a combination of fact tables and dimension tables—two fundamental components of a data warehouse schema. This document aims to provide a comprehensive understanding of these components, their purposes, and their logical structures, specifically in the context of capturing user interactions and events.

### What Are Fact Tables?

Fact tables are the backbone of a data warehouse, designed to store quantitative data that can be analyzed and aggregated. These tables capture specific events or transactions that occur within a system. Each row in a fact table corresponds to a single event or transaction, and the table consists of two main types of columns:
- **Measures**: Numeric data that can be summed, averaged, or otherwise aggregated. In this context, measures might include counts of successful authentications, duration of listening events, and counts of page views.
- **Foreign Keys**: References to dimension tables, which provide additional context to the measures. These keys allow us to join fact tables with dimension tables and enrich the analysis with descriptive information, such as user details or location.

### What Are Dimension Tables?

Dimension tables complement fact tables by providing descriptive context to the quantitative data. They contain attributes that describe the dimensions of the events or transactions stored in the fact tables. Each row in a dimension table corresponds to a unique instance of a particular dimension, such as a specific user, location, or time period. Dimension tables typically have:
- **Primary Key**: A unique identifier for each dimension instance. This key is used to join dimension tables with fact tables.
- **Descriptive Attributes**: Columns that provide additional information about the dimension. For example, a user dimension table might include attributes like first name, last name, gender, and subscription level.

### Why Use Facts and Dimensions?

The combination of fact and dimension tables enables a multi-dimensional view of data, often referred to as a "star schema" or "snowflake schema." This approach offers several benefits:
1. **Efficiency**: By separating quantitative data (facts) from descriptive data (dimensions), storage can be optimized, and query performance can be improved.
2. **Flexibility**: Dimension tables allow the addition of new descriptive attributes without modifying the fact tables, making it easier to adapt to changing business needs.
3. **Detailed Analysis**: Fact tables provide granular data on specific events or transactions, while dimension tables offer rich context. This combination allows for detailed and insightful analysis, such as tracking user authentication patterns, understanding listening habits, or identifying trends in page views.

### Structure of This Document

In the following sections, the specific fact tables and dimension tables used in our data warehouse are explained. Each section includes:
- A description of the table's purpose.
- An explanation of the schema and key columns.
- The logic behind the table's design and its role in the overall data model.

By the end of this document, there will be a thorough understanding of how facts and dimensions work together to provide a robust framework for data analysis and reporting.

## Fact Tables

### Auth Events Fact Table
The Auth Events fact table captures authentication events with the following schema:
- **auth_id**: A unique identifier for each authentication event.
- **timestamp_ms**: The timestamp of the event in milliseconds.
- **user_id**: The ID of the user.
- **session_id**: The ID of the session.
- **location_id**: A unique identifier for the location.
- **subscription_level**: The user's subscription level.
- **item_in_session**: The item number within the session.
- **success_flag**: Indicates whether the authentication was successful.
- **auth_timestamp**: The timestamp of the event in a readable format.
- **auth_date**: The date of the event.
- **created_at**: The timestamp when the record was created.

### Listen Events Fact Table
The Listen Events fact table stores listening activities with the following schema:
- **listen_id**: A unique identifier for each listening event.
- **timestamp_ms**: The timestamp of the event in milliseconds.
- **user_id**: The ID of the user.
- **session_id**: The ID of the session.
- **song_id**: A unique identifier for the song.
- **artist_id**: A unique identifier for the artist.
- **location_id**: A unique identifier for the location.
- **item_in_session**: The item number within the session.
- **duration_seconds**: The duration of the listening event in seconds.
- **auth_status**: The authentication status.
- **subscription_level**: The user's subscription level.
- **success_flag**: Indicates whether the listening event was successful.
- **listen_timestamp**: The timestamp of the event in a readable format.
- **listen_date**: The date of the event.
- **created_at**: The timestamp when the record was created.

### Page View Events Fact Table
The Page View Events fact table logs page views with the following schema:
- **page_view_id**: A unique identifier for each page view event.
- **timestamp_ms**: The timestamp of the event in milliseconds.
- **user_id**: The ID of the user.
- **session_id**: The ID of the session.
- **location_id**: A unique identifier for the location.
- **page**: The name of the page viewed.
- **method**: The HTTP method used.
- **http_status**: The HTTP status code.
- **auth_status**: The authentication status.
- **subscription_level**: The user's subscription level.
- **item_in_session**: The item number within the session.
- **success_flag**: Indicates whether the page view event was successful.
- **page_view_timestamp**: The timestamp of the event in a readable format.
- **page_view_date**: The date of the event.
- **created_at**: The timestamp when the record was created.

### Status Change Events Fact Table
The Status Change Events fact table records status changes with the following schema:
- **status_change_id**: A unique identifier for each status change event.
- **timestamp_ms**: The timestamp of the event in milliseconds.
- **user_id**: The ID of the user.
- **session_id**: The ID of the session.
- **location_id**: A unique identifier for the location.
- **change_page**: The page where the status change occurred.
- **subscription_level**: The user's subscription level.
- **status_code**: The status code.
- **item_in_session**: The item number within the session.
- **success_flag**: Indicates whether the status change event was successful.
- **status_change_timestamp**: The timestamp of the event in a readable format.
- **status_change_date**: The date of the event.
- **created_at**: The timestamp when the record was created.

## Dimension Tables

### Artist Dimension
The Artist Dimension captures distinct artist names with the following schema:
- **artist_id**: A unique identifier for each artist, created using an MD5 hash of the artist name.
- **artist_name**: The name of the artist.
- **created_at**: The timestamp when the record was created.

### Location Dimension
The Location Dimension captures unique location details with the following schema:
- **location_id**: A unique identifier for each location, created using an MD5 hash of the concatenated city, state, and ZIP code.
- **city**: The name of the city.
- **state**: The name of the state.
- **zip**: The ZIP code of the location.
- **latitude**: The latitude coordinate of the location.
- **longitude**: The longitude coordinate of the location.
- **created_at**: The timestamp when the record was created.

### Session Dimension
The Session Dimension captures session details with the following schema:
- **session_id**: A unique identifier for each session.
- **user_id**: The ID of the user associated with the session.
- **session_start_time**: The start time of the session, converted from Unix timestamp.
- **session_end_time**: The end time of the session, converted from Unix timestamp.
- **session_date**: The date of the session, derived from the start time.
- **session_duration_seconds**: The duration of the session in seconds.
- **total_actions**: The total number of actions performed during the session.
- **created_at**: The timestamp when the record was created.

### Song Dimension
The Song Dimension captures unique song details with the following schema:
- **song_id**: A unique identifier for each song, created using an MD5 hash of the concatenated song name and artist name.
- **song_name**: The name of the song.
- **artist_name**: The name of the artist.
- **duration_seconds**: The duration of the song in seconds.
- **created_at**: The timestamp when the record was created.

### Timestamp Dimension
The Timestamp Dimension captures unique timestamps and breaks them down into various time-related components with the following schema:
- **timestamp_ms**: The original timestamp in milliseconds.
- **timestamp**: The timestamp converted to a readable datetime format.
- **date**: The date portion of the timestamp.
- **year**: The year of the timestamp.
- **month**: The month of the timestamp.
- **day**: The day of the timestamp.
- **hour**: The hour of the timestamp.
- **minute**: The minute of the timestamp.
- **second**: The second of the timestamp.
- **day_of_week**: The name of the day of the

## Conclusion
Fact and dimension tables are essential components of a data warehouse, providing the structure needed for efficient data analysis and reporting. Fact tables capture quantitative data, while dimension tables provide descriptive context. Together, they enable detailed and insightful analysis, helping organizations make data-driven decisions.

