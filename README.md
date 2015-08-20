# grails_v2.5.1_Tomcat_MariaDB Build

#Docker Run Command
#Please don't execute with Root priv

sudo docker run -it -e MARIADB_ROOT_PASSWORD=root -p 8080:8080 -p 3006:3006 -v /path/data.sql:/path/data.sql -v /path/webapps/:/opt/tomcat/webapps al34n1x/grails_tomcat_mariadb /bin/bash


#### END OF FILE ####
