######
# e003_publisher/site.pp
######

# Create the repositories filesystem and mount it at /repositories
# In the lab /rpool/repositories will already exist this will only change the
# mountpoint. We have also pre-cached a small number of packages
zfs { 'rpool/repositories':
  ensure     => present,
  mountpoint => '/repositories';
}

$lab_pkg = hiera('lab::pkg',undef)
# Configure the publisher for the lab
pkg_publisher { 'solaris':
  origin  => [
    '/repositories/publisher/solaris',
    $lab_pkg['solaris']['origin']
  ],
  require => Zfs['rpool/repositories'];
}

# Configure pkg.repod to serve our partial copy of the repo
# By default pkg/server:default runs on port 80
svccfg {
  # See svc:/application/pkg/mirror:default
  # for an automated service to maintain a true local mirror
  'svc:/application/pkg/server:default/:properties/pkg/inst_root':
    value   => '/repositories/publisher/solaris',
    require => Pkg_publisher['solaris'],
    notify  => Service['svc:/application/pkg/server:default'];
}

# Start the service
service { 'svc:/application/pkg/server:default':
  ensure => running
}

# View the list of packages in the local repository
# pkgrepo -s http://localhost/solaris list
