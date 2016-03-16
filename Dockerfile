FROM partlab/ubuntu
MAINTAINER Alejandro Casas "casas.alejandro@gmail.com"

##################################################################
#       Dockerfile to build Grails V 2.5.1 environment                
#                   Based on Ubuntu 14.04    
#                     By Alejandro Casas    
#                          AL34N!X
##################################################################


ENV TOMCAT_VERSION 8.0.24

# Set locales
RUN locale-gen en_GB.UTF-8
ENV LANG en_GB.UTF-8
ENV LC_CTYPE en_GB.UTF-8
ENV DEBIAN_FRONTEND noninteractive
ENV INITRD No

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
    git \
    build-essential \
    curl \ 
    wget \
    software-properties-common \
    ant \
    zip


#JDK Installation Process from n3ziniuka5/ubuntu-oracle-jdk Build
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
RUN echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections
RUN apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common && \
    add-apt-repository ppa:webupd8team/java && \
    apt-get update && \
    apt-get install -y --no-install-recommends oracle-java8-installer 


#Workaround to use source command that is part of the bash built-in services required for next steps 
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

#Install GVM, Grails Version 2.5.1, Gradle and Groovy 
RUN /bin/bash && \
    curl -s get.gvmtool.net | bash && \
    /bin/sed -i 's/gvm_auto_answer=false/gvm_auto_answer=true/g' ~/.gvm/etc/config && \
    source "$HOME/.gvm/bin/gvm-init.sh" && \
    gvm install grails 2.4.4 && \
    gvm install gradle && \
    gvm install groovy
    
# Get Tomcat
RUN wget --quiet --no-cookies \
    http://apache.rediris.es/tomcat/tomcat-8/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz -O /tmp/tomcat.tgz

# Uncompress
RUN tar xzvf /tmp/tomcat.tgz -C /opt && \
    mv /opt/apache-tomcat-${TOMCAT_VERSION} /opt/tomcat && \
    rm /tmp/tomcat.tgz

# Remove garbage
RUN rm -rf /opt/tomcat/webapps/examples && \
    rm -rf /opt/tomcat/webapps/docs && \
    rm -rf /opt/tomcat/webapps/ROOT

# Install MySQL
RUN apt-get install -y mysql-server


# Add admin/admin user
ADD tomcat-users.xml /opt/tomcat/conf/

#Set environment variables
ENV CATALINA_HOME /opt/tomcat
ENV ANT_HOME /usr/share/ant
ENV PATH $PATH:$JAVA_HOME/bin:$GRAILS_HOME/bin:$ANT_HOME/bin:$GRADLE_HOME/bin:$GROOVY/bin:$CATALINA_HOME/bin

#Expose Ports
EXPOSE 8080
EXPOSE 8009
EXPOSE 3306

#Working Dirs
WORKDIR /opt/tomcat

#Clean up
RUN rm -rf /var/lib/apt/lists/*


# Start & Import DB
ADD scientiam.sql /tmp/dump.sql
ADD initdb.sh /tmp/initdb.sh
RUN /tmp/initdb.sh

RUN /usr/bin/mysqld_safe & \
    sleep 10s &&\
    echo "use mysql; update user set password=PASSWORD("password") where User='root'; FLUSH PRIVILEGES;" | mysql
