FROM fedora
MAINTAINER jlabocki@redhat.com

# This Dockerfile installs the following components of Keystone in a docker image
# 
# 
# 

#Timestamps are always useful
RUN date > /root/date

#Install required packages
RUN yum install python-pbr git python-devel python-setuptools python-pip gcc gcc-devel libxml2-python libxslt-python python-lxml sqlite python-repoze-lru -y
#RUN yum install python-sqlite2 python-lxml python-greenlet-devel python-ldap sqlite-devel openldap-devel -y

#Clone Keystone and setup
WORKDIR /opt
RUN git clone http://github.com/openstack/keystone.git
WORKDIR /opt/keystone
RUN python setup.py install

#Configure Keystone
RUN mkdir -p /etc/keystone
RUN cp etc/keystone.conf.sample /etc/keystone/keystone.conf
RUN cp etc/keystone-paste.ini /etc/keystone/
RUN sed -ri 's/#driver=keystone.identity.backends.sql.Identity/driver=keystone.identity.backends.sql.Identity/' /etc/keystone/keystone.conf 
RUN sed -ri 's/#connection=<None>/connection=sqlite:\/\/\/keystone.db/' /etc/keystone/keystone.conf
RUN sed -ri 's/#idle_timeout=3600/idle_timeout=200/' /etc/keystone/keystone.conf
RUN sed -ri 's/#admin_token=ADMIN/admin_token=ADMIN/' /etc/keystone/keystone.conf

# The following sections build a script that will be executed on launch via ENTRYPOINT

## Start Keystone
RUN echo "#!/bin/bash" > /root/entrypoint.sh
RUN echo "/usr/bin/keystone-all &" >> /root/entrypoint.sh

## Create Services
#RUN export OS_SERVICE_ENDPOINT=http://localhost:35357/v2.0
#RUN export OS_SERVICE_TOKEN=ADMIN
#RUN export OS_AUTH_URL=http://127.0.0.1:35357/v2.0/
RUN echo '/usr/bin/keystone --os_auth_url http://127.0.0.1:35357/v2.0/ --os-token ADMIN --os-endpoint http://127.0.0.1:35357/v2.0/ service-create --name=ceilometer --type=metering --description="Ceilometer Service"' >> /root/entrypoint.sh
RUN chmod 755 /root/entrypoint.sh

#Added for debugging, probably remove later
#RUN ps -ef |grep -i key > /root/keystone.ps

#This you will need to substitute your values and run later - the values are:
# CEILOMETER_SERVICE = the id of the service created by the keystone service-create command
# SERVICE_HOST = the host where the Ceilometer API is running
RUN echo 'keystone endpoint-create --region RegionOne --service_id $CEILOMETER_SERVICE --publicurl "http://$SERVICE_HOST:8777/"  --adminurl "http://$SERVICE_HOST:8777/" --internalurl "http://$SERVICE_HOST:8777/"' > /root/postlaunchconfig.sh

#ENTRYPOINT /root/entrypoint.sh
