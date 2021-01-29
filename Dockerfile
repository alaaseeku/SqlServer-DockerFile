FROM ubuntu:18.04
RUN apt-get update
RUN apt-get install -y wget sudo supervisor
RUN wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb
RUN dpkg -i packages-microsoft-prod.deb
RUN  apt-get install apt-transport-https
RUN apt-get update
RUN apt-get install -y dotnet-sdk-2.2

RUN apt-get install -y nginx
COPY MyApp.conf /etc/nginx/sites-enabled/

COPY MyApp.service /etc/systemd/system/
RUN useradd wwwdata
RUN mkdir /var/www/html/asp
RUN chown wwwdata.wwwdata /var/www/html/asp

RUN apt-get install -y software-properties-common
RUN wget -q http://debian.opennms.org/dists/opennms-23/main/binary-all/oracle-java8-installer_8u131-1~webupd8~2_all.deb
RUN add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/16.04/mssql-server-preview.list)"
RUN apt-get install -y expect binutils java-common locales
COPY inst_script2 /inst_script2
RUN chmod +x /inst_script2
RUN ./inst_script2

RUN dpkg --configure -a
RUN apt-get -y install libgdiplus
RUN ln -s /usr/lib/libgdiplus.so /usr/lib/libgdiplus.dll


#RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
#RUN apt-get update
#RUN apt-get install -y mssql-server



RUN wget http://www-eu.apache.org/dist/maven/maven-3/3.5.4/binaries/apache-maven-3.5.4-bin.tar.gz
RUN tar xzf apache-maven-3.5.4-bin.tar.gz
RUN ln -s /apache-maven-3.5.4 /usr/local/apache-maven
COPY apache-maven.sh /etc/profile.d/
#RUN source /etc/profile.d/apache-maven.sh
RUN rm -f apache-maven-3.5.4-bin.tar.gz


RUN  apt-get update
RUN  apt-get install --no-install-recommends --yes   gnupg
RUN DISTRO="bionic"
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 5AFA7A83
RUN tee "/etc/apt/sources.list.d/kurento.list" >/dev/null <<EOF
RUN echo "deb [arch=amd64] http://ubuntu.openvidu.io/6.10.0 bionic kms6" >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get install --yes kurento-media-server
RUN rm -rf /etc/kurento/kurento.conf.json
COPY kurento.conf.json /etc/kurento/
#RUN service kurento-media-server start

COPY MyApp.tgz /etc/ssl/private/
RUN tar -xvf /etc/ssl/private/MyApp.tgz -C /etc/ssl/private/
COPY MyAppFiles.tgz /
RUN tar -xvf MyAppFiles.tgz

RUN apt-get install -y git
RUN git clone https://github.com/Kurento/kurento-tutorial-java.git
#RUN cd kurento-tutorial-java/kurento-player
#RUN git checkout 6.9.0
#RUN mvn -U clean spring-boot:run
RUN echo "hi"
ENV supervisor_conf /etc/supervisor/supervisord.conf
COPY supervisord.conf ${supervisor_conf}
#RUN /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf &
#CMD source /etc/profile.d/apache-maven.sh
#WORKDIR /kurento-tutorial-java/kurento-player
#CMD /usr/local/apache-maven/bin/mvn -U clean spring-boot:run &
#WORKDIR /
COPY startup.sh /startup.sh
CMD ["./startup.sh"]

EXPOSE 443 8880 8888 3001 8443