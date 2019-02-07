# Amicrogenesis

Copies microgrenes logged in the Amicrogenesis Asana task and copies them into a Postgres database, which can then be read by Google Data Studio.

## Usage
```
docker-compose up
```

## Overview

Most of the work happens in `./tasks/amicrogenesis.sh`. This:
- Gets all the tasks in the Amicrogenesis project
- Formats the JSON response and extracts the value in the `microgenes` custom field
- Generates a SQL command that
    - Inserts the response into the `microgenic_tasks` table of the Postgres DB
    - Generates a summary snapshot with the `generate_microgene_summary()` function
