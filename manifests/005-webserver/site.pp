# 004-nodes/site.pp

# This is not acceptable syntax for a normal puppet class
# classes must be defined in their own directories the lab
# configuration of syntastic disables that check

# Define a base class for all nodes
class base {
# Copy zshrc from the lab 'module'
  file { '/root/.zshrc':
    ensure => present,
    source => 'puppet:///modules/lab/zshrc';
  }

# Configure the publisher for the lab
  pkg_publisher { 'solaris':
    #origin      => ['http://pkg.oracle.com/solaris/release/'],
    origin      => ['http://ipkg.us.oracle.com/solaris12/minidev/'],
  }
}

# Puppet master specific resources
class master {
  package { ['puppetlabs-mysql','puppetlabs-apache']:
    ensure => present,
  }
}


# Define resources for our webserver
class webserver {
  # Use the apache module to install apache
  class { 'apache': }

  # Use the mysql module to install mysql
  include '::mysql::server'
  class { '::mysql::server':
    root_password           => 'strongpassword',
    remove_default_accounts => true,
  }
}

# Node statements in site.pp is not the recommended way to classify nodes it
# isn't tuly managible at scale. See: Language: Node definitions in Puppet docs
# for more information on classifying nodes

# Set the default node behavior. In conjunction with the base class and no
# additional nodes this is identical to the previous configurations. i.e. all
# nodes have the same resources applied
node default {
  include base
}

node /puppet-lab.*/ {
  include base
  include master
}

node /www.*/ {
  include base
  include webserver
}
