$labfiles  ='/root/HOL7712-Solaris-Puppet'
$manifests ="${labfiles}/manifests"
$site_pp = '/etc/puppet/manifests/site.pp'

notice("Copying lab files for ${tag}")

# Copy files around with rsync
  # Ensure rsync is installed. This uses the
  # puppetlabs-rsync module
  class { 'rsync': package_ensure => present }

  # Set default parameters for Rsync::Get
  Rsync::Get {
    recursive => true,
    path      => '/etc/puppet/manifests',
    exclude   => 'site.pp',
    source    => "${::manifests}/${::tag}/",
    tag       => [$::tag]
  }

  # Copy the set of manifests to /etc/puppet/manifests
  # without a tag supplied via --tags all resources will be executed
  # You probably don't want to do that but nothing is preventing you from doing
  # it

  rsync::get { $::tag: }
  # This ends up looking something like
  # rsync::get { '001-simple':
  #   recursive => true,
  #   path      => '/etc/puppet/manifests',
  #   exclude   => 'site.pp',
  #   source => "${::manifests}/001-simple/"; }

  Concat {
    owner  => 'puppet',
    group  => 'puppet',
    mode   => '0644',
    tag    => [$::tag]
  }

  concat { $::site_pp: }

  # Set the default target for Concat fragment
  Concat::Fragment {
    target => $::site_pp,
    source => "${::manifests}/${::tag}/site.pp",
    tag    => [$::tag]
  }

  # Add additional tags to build up file...probably
  concat::fragment { $::tag: }
