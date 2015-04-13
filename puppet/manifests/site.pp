node 'tomcat1','tomcat2' {
  $environment = "PuppetDemo"
  include java
  include xld-base
  include xld-tomcat
}

node 'tomcat3' {
  $environment = "PuppetDemo"
  include java
  include xld-base
  include xld-tomcat
  #include xld-app
}

node 'dbprod' {
  $environment = "PuppetDemo"
  include xld-base
  include xld-mysql
}


