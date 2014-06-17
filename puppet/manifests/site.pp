# create a new run stage to ensure certain modules are included first
stage { 'pre':
  before => Stage['main']
}

# add the baseconfig module to the new 'pre' run stage
class { 'baseconfig':
  stage => 'pre'
}

# set defaults for file ownership/permissions
File {
  owner => 'root',
  group => 'root',
  mode  => '0644',
}

# all boxes get the base config
include baseconfig

node 'tomcat1','tomcat2' {
  include xld-tomcat
}

node 'tomcat3' {
  include xld-tomcat
  include xld-app
}

node 'jbossqa' {
  $environment = "QA"
  include xld-jbossas
}

node 'jbossprod1','jbossprod2' {
  $environment = "Production"
  include xld-jbossas
}

node 'dbqa' {
  $environment = "QA"
  include xld-mysql
}

node 'dbprod' {
  $environment = "Production"
  include xld-mysql
}


node 'base' {
  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }
  include java
}

