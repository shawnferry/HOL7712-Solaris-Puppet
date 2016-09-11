######
# e005_nodes/site.pp
######

# This is not acceptable syntax for a normal puppet class
# classes must be defined in their own directories the lab
# configuration of syntastic disables that check


# Define a base class for all nodes
class lab::base {

  $lab_homedir = hiera('lab::homedir', '/root')
  $lab_pkg = hiera('lab::pkg')

# Copy zshrc from the lab 'module'
  file { "${lab_homedir}/.zshrc":
    ensure => present,
    source => 'puppet:///modules/lab/zshrc';
  }

  pkg_publisher { $lab_pkg['solaris']['publisher']:
    origin      => $lab_pkg['solaris']['origin']
  }
}

# Puppet master specific resources
class lab::master {
  $lab_sources = hiera('lab::sources')

  file { '/var/lib/hiera':
    source  => "${lab_sources}/hiera",
    recurse => true
  }
}

# Define resources for our webserver
class lab::webserver {
  # Use the apache module to install apache
  class { 'apache': }
}

# Node statements in site.pp is not the recommended way to classify nodes it
# isn't tuly managible at scale. See: Language: Node definitions in Puppet docs
# for more information on classifying nodes

# Set the default node behavior. In conjunction with the base class and no
# additional nodes this is identical to the previous configurations. i.e. all
# nodes have the same resources applied
node default {
  include lab::base
}

node /puppet-lab.*/ {
  include lab::base
}

node /www.*/ {
  include lab::base
  include lab::webserver
}
