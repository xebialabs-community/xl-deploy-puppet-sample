node 'tomcat1','tomcat2' {
  $environment = "PuppetDemo"
  include java
  include xld-base
  include xld-tomcat
}


node 'dbprod' {
  $environment = "PuppetDemo"
  include xld-base
  include xld-mysql
}

node 'tomcat3' {
  $environment = "PuppetDemo"
  include java
  include xld-base
  include xld-tomcat
#include xld-app
}

