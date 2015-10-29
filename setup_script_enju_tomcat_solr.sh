# !/bin/sh
## setup script tomcat and solr.

echo "setup tomcat and solr: start."

TOMCAT_VERSION="7.0.59"
TOMCAT_NAME="apache-tomcat-${TOMCAT_VERSION}"
TOMCAT_ARC_NAME="${TOMCAT_NAME}.tar.gz"
SOLR_VERSION="3.6.2"
SOLR_NAME="apache-solr-${SOLR_VERSION}"
SOLR_ARC_NAME="${SOLR_NAME}.tgz"
export JAVA_HOME=/usr/lib/jvm/java-openjdk

# 必要なアーカイブ群がすでに存在するかどうかチェック
if ! [ -f /usr/local/src/enju_trunk_support.zip ]; then
  echo "enju_trunk_support.zip does not exist."
  exit 1
fi
if ! [  -f /usr/local/src/${TOMCAT_ARC_NAME} ]; then
  echo "${TOMCAT_ARC_NAME} does not exist."
  exit 1
fi
if ! [ -f /usr/local/src/${SOLR_ARC_NAME} ]; then
  echo "${SOLR_ARC_NAME} does not exist."
  exit 1
fi

echo "step B-1: prepare setting"
cd /usr/local/src
unzip -o enju_trunk_support.zip

echo "step B-2: install tomcat7"
cd /opt
tar zxvf /usr/local/src/${TOMCAT_ARC_NAME}
 
ln -s ${TOMCAT_NAME} /opt/tomcat
useradd -d /opt/tomcat -s /sbin/nologin tomcat
 
chown -R tomcat. /opt/${TOMCAT_NAME}
chown -R tomcat. /opt/tomcat
chmod go+rx tomcat
 
cd /opt/tomcat/bin
tar xvzf commons-daemon-native.tar.gz
cd commons-daemon-1.0.15-native-src/unix
./configure --with-os=${JAVA_HOME}/include/linux
make
chown tomcat. jsvc
cp jsvc ../..
 
cp /usr/local/src/enju_trunk_support-jst/tomcat7 /etc/init.d/tomcat7
cd /etc/init.d/
chmod +x /etc/init.d/tomcat7
chkconfig tomcat7 on
 
# port番号変更(8080 -> 8983) / useBodyEncodingForURI 追加
echo "change port number (8080 => 8983)"
\cp /usr/local/src/enju_trunk_support-jst/tomcat-${TOMCAT_VERSION}-server.xml /opt/tomcat/conf/server.xml
#cp /opt/tomcat/conf/server.xml  /opt/tomcat/conf/server.xml_backup
#sed -i -e 's/Connector port=\"8080\"/Connector port=\"8983\"/g' /opt/tomcat/conf/server.xml
#sed -i -e 's/redirectPort=\"8443\"/redirectPort=\"8443\" useBodyEncodingForURI=\"true\"/' /opt/tomcat/conf/server.xml
 
service tomcat7 start
sleep 30
service tomcat7 stop
# 起動してディレクトリを作成する。
# curl http://localhost:8983/
# htmlが表示されればOK。
 
echo "step B-3: install solr"

cd /usr/local/src/
tar xf ${SOLR_ARC_NAME}
mkdir -p /opt/solr
cp -R /usr/local/src/${SOLR_NAME}/example /opt/solr
cp /usr/local/src/${SOLR_NAME}/dist/${SOLR_NAME}.war /opt/solr/

cp /usr/local/src/enju_trunk_support-jst/tools/service/tomcat-conf/unix/solr.xml /opt/tomcat/conf/Catalina/localhost/
\cp /usr/local/src/enju_trunk_support-jst/templates/solr/conf/* /opt/solr/example/solr/conf/
 
service tomcat7 start
 
echo "setup tomcat and solr: end."