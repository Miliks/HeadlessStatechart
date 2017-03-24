FROM ubuntu:latest
MAINTAINER Mila

	# install needed packages 
RUN apt-get update && \
    apt-get -y install openjdk-8-jre openjdk-8-jdk ant git nano

RUN cd / && \ 
        git clone https://github.com/jolie/jolie.git && \ 
        cd jolie && \ 
	ant && ant install

       
        # copy source repository and script with logic 

#COPY eu.hyvar.metadata.deltaecore.exampleHeadless /home/hyvar

COPY hyvar /home/hyvar

COPY yakindu-sctpro /home/yakindu-sctpro
RUN chmod -R 774 /home/yakindu-sctpro
RUN cd /home/yakindu-sctpro
RUN export PATH=$PWD:$PATH
RUN export DISPLAY=:1


 	# Update the paths 
ENV JOLIE_HOME /usr/lib/jolie 
 	
 
	# Setup the service
EXPOSE 8080 
WORKDIR /home/hyvar
CMD ["jolie", "hyvar_statechart_receiver.ol", "&"] 
