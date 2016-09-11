######
# e005_reverse_proxy/site.pp
#####

# In our previous examples we have enabled a package server and apache
# both of which use port 80 by default. We will change the port on
# pkg/server:default and create a proxy in Apache

#XXX
# create repo-docroot
# change index.html to show it's a repo
# add repo entry to /etc/hosts
# fix or remove disabled vhost settings

svccfg {
  # Set the port for pkg/server:default to 8080
  'svc:/application/pkg/server:default/:properties/pkg/port':
  # See svc:/application/pkg/mirror:default
    value   => '8080',
    require => Pkg_publisher['solaris'],
    notify  => Service['svc:/application/pkg/server:default'];

  'svc:/application/pkg/server:default/:properties/pkg/proxy_base':
  # See svc:/application/pkg/mirror:default
    value   => 'http://puppet:8080/solaris',
    require => Pkg_publisher['solaris'],
    notify  => Service['svc:/application/pkg/server:default'];
}

# See Oracle Docs for 'Depot Server Apache Configuration'
apache::vhost { 'repo':
  docroot               => '/var/apache2/2.4/repo-htdocs',
  redirect_source       => ['/solaris'],
  redirect_dest         => ['http://localhost:8080/solaris/'],
  allow_encoded_slashes => 'nodecode',
# keepalive              => 'on',
# max_keepalive_requests => '10000',
#  proxy_timeout         => '30',
#  proxy_requests        => 'off',
  filters               => [
    'FilterDeclare  COMPRESS',
    'FilterProvider COMPRESS DEFLATE "%{Content_Type} = \'text/html\'"',
    'FilterProvider COMPRESS DEFLATE "%{Content_Type} = \'application/javascript\'"',
    'FilterProvider COMPRESS DEFLATE "%{Content_Type} = \'text/css\'"',
    'FilterProvider COMPRESS DEFLATE "%{Content_Type} = \'text/plain\'"',
  ],
  proxy_pass            => [
    { 'path'     => '/solaris',
      'url'      => 'http://localhost:8080',
      'params'   => {'max'                         => '200'},
      'keywords' => ['nocanon']
    }
  ],

}
