FROM bbustin/js-docker

# download and install Simba JDBC BigQuery driver
RUN  \
    wget https://storage.googleapis.com/simba-bq-release/jdbc/SimbaJDBCDriverforGoogleBigQuery42_1.0.6.1008.zip -O /tmp/SimbaJDBCDriverforGoogleBigQuery.zip && \
    unzip /tmp/SimbaJDBCDriverforGoogleBigQuery.zip -d /tmp/simba && \
    mv /tmp/simba/*.jar /usr/local/tomcat/lib/ && \
    rm -rf /tmp/*

# use applicationContext.xml with autoCommitUnsupportedDrivers set forthe Simba BigQuery JDBC driver
COPY applicationContext.xml /usr/src/jasperreports-server/buildomatic/conf_source/ieCe/