# JasperReports Server for Docker with BigQuery support
### Community Edition with Simba JDBC Driver for Google BigQuery

Builds upon the [bbustin/js-docker](https://hub.docker.com/r/bbustin/js-docker/) image.
Adds the Simba JDBC Driver for Google BigQuery and modifies the WEB-INF/applicationContext.xml
to allow the driver to work.

This is probably no ready for production use. USe at your own risk.

Please also refer to the [Jasper Server documentation](http://community.jaspersoft.com/project/jasperreports-server)

There is a professional version of Jasper Server available with an officially supported way of deploying using
docker. [Jasper Server Comparison of Jasper Server versions](https://www.jaspersoft.com/editions)

## How to use

The easiest way to use this image is with Docker-compose: `docker-compose up -d`

Then you should be able to browse to [http://localhost:8080/jasperserver](http://localhost:8080/jasperserver)
and log in with jasperadmin/jasperadmin.

### Authentication with BigQuery

You will need to have a service account and the keys for that service account. You can then use
Docker secrets or another mechanism for handling sensitive data to make the keys accessible
to your container. Ideally, you'll use a secure mechanism made for this purpose, but you can also
use insecure means to do it.

In the end what is needed is a way at runtime for the keys to be accessible inside the container as a file.
When configuring your data source on the server, you need to reference where the driver can access
the keys.

#### Example: Docker secrets
This example uses Docker secrets.

Assuming key is named `bigquery.p12` and is located in the same folder as `docker-compose.yml`.

- create the docker secret: `docker secret create bigquery.p12 ./bigquery.p12`
- create docker containers using docker stack: `docker stack deploy --compose-file=docker-compose.yml jasper`
- find the name of your jasperserver service from the output of the previous step. In my case it is `jasper_jasperserver`.
- update the service with the secret: `docker service update --secret-add="bigquery.p12" jasper_jasperserver`

Docker secrets automatically appear as files under `/run/secrets/`, so this secret is available inside the
container at `/run/secrets/bigquery.p12`.

`jdbc:bigquery://https://www.googleapis.com/bigquery/v2:443;ProjectId=<project_name>;timeout=240;OAuthType=0;OAuthServiceAcctEmail=<service_account_email>;OAuthPvtKeyPath=/run/secrets/bigquery.p12`

#### Example: Local development witout a Docker swarm
For local development without a Docker swarm, there appears to be a way to fake Docker secrets. This is
probably very insecure. Docker secrets are designed to encrypt data at rest. Without a swarm, I do
not believe this encryption is possible, so it is likely stored in plain text somewhere.

Assuming key is named `bigquery.p12` and is located in the same folder as `docker-compose.yml`.

- Add the following to the top of the `docker-compose.yml` file right below `version`:
`secrets:
  bigquery.p12:
      file: "./bigquery.p12"`

 - Modify the jasperserver service so it starts like this:
 `services:
  jasperserver:
    secrets:
      - bigquery.p12
    # to build instead of using image
    # - change version towards top of file from 3.1 to 2
    # - comment image line
    # - uncomment build line
    image: bbustin/js-docker-bigquery`

- bring up the containers `docker-compose up -d`

Docker secrets automatically appear as files under `/run/secrets/`, so this secret is available inside the
container at `/run/secrets/bigquery.p12`.

`jdbc:bigquery://https://www.googleapis.com/bigquery/v2:443;ProjectId=<project_name>;timeout=240;OAuthType=0;OAuthServiceAcctEmail=<service_account_email>;OAuthPvtKeyPath=/run/secrets/bigquery.p12`

#### For more information

Download the Simba JDBC Driver [here](https://cloud.google.com/bigquery/partners/simba-drivers/), unzip it, and read the included PDF.