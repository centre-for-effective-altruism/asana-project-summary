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

## Getting setup
- See an example .env file in `1password.Development/low-security/Amicrogenesis Environment`
  - Create Asana [personal access token](https://asana.com/guide/help/api/api)
- General tips
  - These instructions are generally meant to be followed after running docker compose up
  - You can edit the scripts to put echo statements, they should hot-reload
  - You might want 3 terminals: docker compose up logs, one in the /tasks directory and one in the /postgres directory
- Install docker app on your mac
- In the project root, run docker compose up
- In a separate terminal, in /postgres run ./psql to test your ability to connect to the db
 - Verify that there's nothing there yet by running \d
 - Exit
- In /postgres run ./sqitch deploy --verify
 - If you ever want to undo this, run ./sqitch revert
- In /tasks run `docker exec -it asana-project-summary_tasks_1 /bin/sh` to enter the tasks docker container
 - Run ./gettasks.sh to test whether you can get things from the project
