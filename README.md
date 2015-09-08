graylog2-vagrant
================

Graylog2 0.20.6 Vagrant Box for easy testing

 * git clone --recursive https://github.com/hggh/graylog2-vagrant.git
 * cd graylog2-vagrant
 * vagrant up
 * vagrant provision # because puppet needs to run twice to create GELF inputs
 * http://localhost:9000/
   * Username: admin
   * Password: yourpassword
 * cronjob runs every minute to push sample data into Graylog2


Graylog2 Stream Dashboard
------------------------------

Access the new Graylog2 Stream Dashboard:

http://127.0.0.1:8080/graylog2-stream-dashboard

Graylog2 server address: http://127.0.0.1:12900

For more information and limitations of the dashboard: https://github.com/Graylog2/graylog2-stream-dashboard
