######
# e005_reverse_proxy/site.pp
#####

# In our previous examples we have enabled a package server and apache
# both of which use port 80 by default. We will change the port on
# pkg/server:default and create a proxy in Apache

svccfg {
  # Set the port for pkg/server:default to 8080
  'svc:/application/pkg/server:default/:properties/pkg/port':
  # See svc:/application/pkg/mirror:default
    value   => '8080',
    require => Pkg_publisher['solaris'],
    notify  => Service['svc:/application/pkg/server:default'];

  'svc:/application/pkg/server:default/:properties/pkg/proxy_base':
  # See svc:/application/pkg/mirror:default
    value   => 'http://repo/publisher',
    require => Pkg_publisher['solaris'],
    notify  => Service['svc:/application/pkg/server:default'];
}

# Create htdocs
file { '/var/apache2/2.4/repo-htdocs':
  ensure => directory,
  before => Apache::Vhost['repo'],
}

# Add an index.html
file { '/var/apache2/2.4/repo-htdocs/index.html':
  content => "It's a Repo!"
}

host { 'puppet-labs.oracle.lab':
  # Where did ipaddres come from ... facter
  ip           => $::ipaddress,
  host_aliases => ['puppet-lab', 'puppet', 'repo']
}

# See Oracle Docs for 'Depot Server Apache Configuration'
apache::vhost { 'repo':
  docroot               => '/var/apache2/2.4/repo-htdocs',
  redirect_source       => ['/publisher'],
  redirect_dest         => ['http://localhost:8080/publisher'],
  allow_encoded_slashes => 'nodecode',
  filters               => [
    'FilterDeclare  COMPRESS',
    'FilterProvider COMPRESS DEFLATE "%{Content_Type} = \'text/html\'"',
    'FilterProvider COMPRESS DEFLATE "%{Content_Type} = \'application/javascript\'"',
    'FilterProvider COMPRESS DEFLATE "%{Content_Type} = \'text/css\'"',
    'FilterProvider COMPRESS DEFLATE "%{Content_Type} = \'text/plain\'"',
  ],
  proxy_pass            => [
    { 'path'     => '/publisher',
      'url'      => 'http://localhost:8080',
      'params'   => {'max'                         => '200'},
      'keywords' => ['nocanon']
    }
  ],

}
