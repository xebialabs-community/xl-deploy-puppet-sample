# Install JBoss

class jbossas (
  $main_version = '5',
  $sub_version = '5.1.1.GA',
  $jbosshost = "jboss-51",
  $jbossdir = "/opt",
  $bind_address = '0.0.0.0',
  $configuration = "default",
  $opts = ''

) {

  Exec {path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ], logoutput => "on_failure"}

  package {"unzip": before => Exec["extract-jboss-server"]}

  group { "jbossas": ensure => present}

  user { "jbossas":
    ensure     => present,
    managehome => true,
    password   => '$6$LkqLbCnk$HEtSWK7hPcZNZlfeVvgkhko.lOzjKa2qQaADTwfEbjZgP9bZPTvFZKDzGQIpAIzPSB/2RYm.WP6Ny/sOT/Sme0',
    gid        => 'jbossas',
    shell      => '/bin/bash',
    require    => Group['jbossas'],
  }

  file { $jbossdir:
    ensure  => "directory",
    owner   => "jbossas",
    group   => "jbossas",
    require => User['jbossas']
  }

  exec { "extract-jboss-server":
    command => "/usr/bin/unzip -o /catalog/JBoss/jboss-${main_version}.${sub_version}.zip -d ${jbossdir}",
    user    => "jbossas",
    group   => "jbossas",
    require => [File[$jbossdir]],
    creates => "${jbossdir}/jboss-${main_version}.${sub_version}"
  }

  file { "${jbossdir}/jboss-${main_version}.${sub_version}/common/lib/mysql-connector-java-5.1.22-bin.jar":
    source  => "/catalog/Oracle/mysql-connector-java-5.1.22-bin.jar",
    ensure  => present,
    owner   => "jbossas",
    group   => "jbossas",
    require => Exec['extract-jboss-server'],
  }

  host { $jbosshost:
    ip => "127.0.0.1",
  }

  file { "generate start-jboss.sh":
    path    => "${jbossdir}/jboss-${main_version}.${sub_version}/bin/start-jboss-${configuration}.sh",
    owner   => "jbossas",
    group   => "jbossas",
    content => template('jbossas/start-jboss.erb'),
    mode    => "0777",
    require => Exec["extract-jboss-server"],
  }

  file { "generate stop-jboss.sh":
    path    => "${jbossdir}/jboss-${main_version}.${sub_version}/bin/stop-jboss-${configuration}.sh",
    owner   => "jbossas",
    group   => "jbossas",
    content => template('jbossas/stop-jboss.erb'),
    mode    => "0777",
    require => Exec["extract-jboss-server"],
  }

  file { "${jbossdir}/jboss-${main_version}.${sub_version}/server/${configuration}/conf/bootstrap/profile.xml":
    source  => "puppet:///modules/jbossas/profile.xml",
    ensure  => present,
    owner   => "jbossas",
    group   => "jbossas",
    require => Exec['extract-jboss-server'],
  }

  exec { 'chown':
    command => "/bin/chown -R jbossas:jbossas ${jbossdir}/jboss-${main_version}.${sub_version}",
    path    => '/bin',
    user    => 'root',
    require => [File["generate start-jboss.sh"],File["generate stop-jboss.sh"]],
  }
}


