1. Download JDK from http://www.oracle.com

2. Install

3. Configure 

       $ vi /etc/profile || ~/.bashrc

         export JAVA_HOME=/opt/jdk
         export JRE_HOME=${JAVA_HOME}/jre
         export CLASSPATH=.:$CLASSPATH:${JAVA_HOME}/lib:${JRE_HOME}/lib
         export PATH=${PATH}:${JAVA_HOME}/bin:${JRE_HOME}/bin

       $ source /etc/profile
       
       $ sudo update-alternatives --install /usr/bin/java java /opt/jdk/bin/java 300
       $ sudo update-alternatives --install /usr/bin/javac javac /opt/jdk/bin/javac 300
       $ sudo update-alternatives --install /usr/bin/jar jar /opt/jdk/bin/jar 300
       $ sudo update-alternatives --install /usr/bin/javah javah /opt/jdk/bin/javah 300
       $ sudo update-alternatives --install /usr/bin/javap javap /opt/jdk/bin/javap 300
       $ sudo update-alternatives --config java
       $ java -version

