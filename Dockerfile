FROM ubuntu:14.04
MAINTAINER Alejandro Casas "casas.alejandro@gmail.com"

RUN echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
RUN echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections

RUN apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common && \
    add-apt-repository ppa:webupd8team/java && \
    apt-get update && \
    apt-get install -y --no-install-recommends oracle-java8-installer && \
    apt-get install -y ant curl zip

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN /bin/bash && \
    curl -s get.gvmtool.net | bash && \
    /bin/sed -i 's/gvm_auto_answer=false/gvm_auto_answer=true/g' ~/.gvm/etc/config && \
    source "$HOME/.gvm/bin/gvm-init.sh" && \
    gvm install grails 2.5.1 && \
    gvm install gradle && \
    gvm install groovy && \
    echo "export ANT_HOME=/usr/share/ant" >> ~/.profile && \
    echo "export PATH=$PATH:$JAVA_HOME/bin:$GRAILS_HOME/bin:$ANT_HOME/bin:$GRADLE_HOME/bin:$GROOVY/bin" >> ~/.profile && \    
    rm -rf /var/lib/apt/lists/*
