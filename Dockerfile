FROM ubuntu:14.04
MAINTAINER Alejandro Casas "casas.alejandro@gmail.com"

##################################################################
#       Dockerfile to build Grails V 2.5.1 environment                
#                   Based on Ubuntu 14.04    
#                     By Alejandro Casas    
##################################################################


#JDK Installation Process from n3ziniuka5/ubuntu-oracle-jdk Build
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
RUN echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections
RUN apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common && \
    add-apt-repository ppa:webupd8team/java && \
    apt-get update && \
    apt-get install -y --no-install-recommends oracle-java8-installer && \

#Install additional packages
    apt-get install -y ant curl zip

#Workaround to use source command that is part of the bash built-in services required for next steps 
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

#Install GVM, Grails Version 2.5.1, Gradle and Groovy 
RUN /bin/bash && \
    curl -s get.gvmtool.net | bash && \
    /bin/sed -i 's/gvm_auto_answer=false/gvm_auto_answer=true/g' ~/.gvm/etc/config && \
    source "$HOME/.gvm/bin/gvm-init.sh" && \
    gvm install grails 2.5.1 && \
    gvm install gradle && \
    gvm install groovy && \
    
#Set environment variables on the .profile 
    echo "export ANT_HOME=/usr/share/ant" >> ~/.profile && \
    echo "export PATH=$PATH:$JAVA_HOME/bin:$GRAILS_HOME/bin:$ANT_HOME/bin:$GRADLE_HOME/bin:$GROOVY/bin" >> ~/.profile && \    

#Clean up
    rm -rf /var/lib/apt/lists/*
