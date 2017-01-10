# openSenseMap archiver

This is the archive script of archive.opensensemap.org. It uses mongoexport, jq and curl to back up the data to sciebo.

### Usage

The best way to start and schedule daily archiving is to start a docker container from this with the following environment variables set:

- `SLACK_HOOK_URL` Slack webhook url to notify run errors
- `DAV_USER` Username for the webdav instance
- `DAV_PASS` Password for the webdav instance
- `DAV_URL` The URL for your webdav instance
- `ARCHIVE_FOLDER` the base folder where you want to store the archive
- `MONGO_USER` Username of your MongoDB
- `MONGO_PASS` Password of your MongoDB user
- `MONGO_DB` The database from which you want to pull the data
- `MONGO_HOST` The host running MongoDB

