$labfiles  ='/root/HOL7712-Solaris-Puppet'
$manifests ="${labfiles}/manifests"
$site_pp = '/etc/puppet/manifests/site.pp'

notice("Building and copying lab files for ${tag}")

# Copy files around with rsync
# Ensure rsync is installed. This uses the
# puppetlabs-rsync module
class { 'rsync': package_ensure => present }

# Set default parameters for Rsync::Get
Rsync::Get {
  recursive => true,
  path      => '/etc/puppet/manifests',
  exclude   => 'site.pp',
  source    => "${::manifests}/${::example}/",
  tag       => [$::example]
}

# Copy everything other than site.pp
rsync::get { $::example: }
# This ends up looking something like
# rsync::get { 'e001_simple':
#   recursive => true,
#   path      => '/etc/puppet/manifests',
#   exclude   => 'site.pp',
#   source => "${::manifests}/e001_simple/"; }

# Set concat defaults to build site.pp
Concat {
  path  => $::site_pp,
  owner => 'puppet',
  group => 'puppet',
  mode  => '0644',
  tag   => [$::example],
}

# Build site.pp based on the example fact
concat { $::example: }

Concat::Fragment {
  target => $::example
}

# There may be a more elegant way to build up this
# structure final site.pp is composed of all the fragments

# Copy example
class e001_simple {
  concat::fragment { 'e001_simple':
    source => "${::manifests}/e001_simple/site.pp",
  }
}

# Copy example
class e002_better {
  concat::fragment { 'e002_better':
    source => "${::manifests}/e002_better/site.pp",
  }
}

# Copy example
class e003_publisher {
  # Include the content from Example 2
  include 'e002_better'
  concat::fragment { 'e003_publisher':
    source => "${::manifests}/e003_publisher/site.pp",
  }
}

# Copy example
class e004_webserver {
  # Include the content from Example 3
  # Example 3 will include Example 2 content
  include 'e003_publisher'
  concat::fragment { 'e004_webserver':
    source => "${::manifests}/e004_webserver/site.pp",
  }
}

# Copy example
class e005_reverse_proxy {
  include 'e004_webserver'
  concat::fragment { 'e005_reverse_proxy':
    source => "${::manifests}/e005_reverse_proxy/site.pp",
  }
}

# Copy example
class e006_nodes {
  concat::fragment { 'e006_nodes':
    source => "${::manifests}/e006_nodes/site.pp",
  }
}

class { $::example: }
