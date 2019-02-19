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
  - After dockerfile change run compose build again
- Install docker app on your mac
- In the project root, run docker compose build
- In the project root, run docker compose up
- In a separate terminal, in /postgres run ./psql to test your ability to connect to the db
 - Verify that there's nothing there yet by running \d
 - Exit
- In /postgres run ./sqitch deploy --verify
 - If you ever want to undo this, run ./sqitch revert
- In /tasks run `docker exec -it asana-project-summary_tasks_1 /bin/sh` to enter the tasks docker container
 - Run ./gettasks.sh to test whether you can get things from the project

## Deploy

[SSH into the AWS EC2 instance](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AccessingInstancesLinux.html) (you'll need the keyfile for authentication)

```sh
# create ssh tunnel
ssh -i /path/my-key-pair.pem ec2-user@ec2-198-51-100-1.compute-1.amazonaws.com
# move to project directory
cd asana-project-summary
# stop the running project
docker-compose down
# pull latest changes
git pull
# rebuild docker images
docker-compose build
# restart the project in detached mode
docker-compose up -d
# update db if necessary
cd ./postgres
./sqitch deploy --verify
cd ..
```

### Deploy troubleshooting

#### `docker-compose build` permissions error

Because we mount directories _within_ the project, Docker may create some files that we don't have permission to modify. This may cause rebuilds to fail:

```
PermissionError: [Errno 13] Permission denied: '/path/to.file'
[12313] Failed to execute script docker-compose
```

The remedy is to make sure that ownership is set correctly for those files:

```
sudo chown -R ec2-user:docker /path/to/file
```
