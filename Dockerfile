FROM fedora
MAINTAINER jlabocki@redhat.com

# This Dockerfile installs the following components of Keystone in a docker image
# 
# 
# 

#Timestamps are always useful
RUN date > /root/date

#Install required packages
#RUN yum install python-sqlite2 python-lxml python-greenlet-devel python-ldap sqlite-devel openldap-devel -y


