#
# In the lab environment these steps will make very few if any changes,
# we assume puppet has alread been installed via pkg install puppet
#

  # enable pupept:master
  service { 'svc:/application/puppet:master':
    ensure => 'running'
  }
  # configure pupept:master
  svccfg { 'svc:/application/puppet:master/:properties/config/server':
    ensure => 'present',
    type   => 'astring',
    value  => 'puppet',
    notify => Service['svc:/application/puppet:master'],
  }

  # enable puppet:agent
  service { 'svc:/application/puppet:agent':
    ensure => 'running'
  }

  # configure puppet:agent
  svccfg { 'svc:/application/puppet:agent/:properties/config/server':
    ensure => 'present',
    type   => 'astring',
    value  => 'puppet',
    notify => Service['svc:/application/puppet:agent'],
  }

  # stop but do not disable puppet:agent
  exec { '/usr/sbin/svcadm mark maintenance puppet:agent': }

  # add host alias puppet 
  host { 'puppet-lab.oracle.lab':
    ensure       => 'present',
    host_aliases => ['puppet-lab', 'puppet'],
    ip           => '192.168.14.227',
    target       => '/etc/inet/hosts',
  }
