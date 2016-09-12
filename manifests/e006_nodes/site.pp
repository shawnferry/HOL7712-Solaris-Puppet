######
# e006_nodes/site.pp
######

# This site.pp it not built from multiple files as the previous
# examples

# This is not acceptable syntax for a normal puppet manifest
# classes must be defined in their own directories the lab
# configuration of syntastic disables that check in puppet-lint

$lab_pkg = hiera('lab::pkg',undef)
$lab_homedir = hiera('lab::homedir', '/root')
$lab_sources = hiera('lab::sources')

# We want all hosts to have the resources defined
# in lab::common
class lab::common {
  # Distribute .zshrc to all systems
  file { "${::lab_homedir}/.zshrc":
    ensure => present,
    owner  => 'root',
    group  => 'root',
    source => 'puppet:///modules/lab/zshrc';
  }

  pkg_publisher { $::lab_pkg['solaris']['publisher']:
    origin => $::lab_pkg['solaris']['origin']
  }

  # Install links character based browser
  package { 'web/browser/links': ensure => present }

}

# All the puppet agents get these resources
class lab::agents {
  host { 'puppet':
    # Where did ipaddres come from ... facter
    ip           => $::serverip,
    host_aliases => ['repo']
  }
}

# resources only for the master server
class lab::master {
  # Install the apache puppet module on the master
  package { 'puppetlabs-apache':
    ensure => present
  }

  # Create and mount the repo filesystem and mount it
  zfs { 'rpool/repositories':
    ensure     => present,
    mountpoint => '/repositories';
  }

  ### This should happen elsewhere/earlier
  #  file { '/var/lib/hiera':
  #    source  => "${lab_sources}/hiera",
  #    recurse => true
  #  }
  }

  # configuration for the package server
  class lab::pkg_server {
    # The package server doesn't require apache. However, our reverse proxy
    # configuration does. Include webserver to get our baseline webserver
    # configuration.
    include lab::webserver

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

    svccfg {
      # Set the port for pkg/server:default to 8080
      'svc:/application/pkg/server:default/:properties/pkg/port':
        # See svc:/application/pkg/mirror:default
        value   => '8080',
        require => Pkg_publisher['solaris'],
        notify  => Service['svc:/application/pkg/server:default'];

      # Set the proxy_base
      'svc:/application/pkg/server:default/:properties/pkg/proxy_base':
        # See svc:/application/pkg/mirror:default
        value   => 'http://repo:8080/solaris',
        require => Pkg_publisher['solaris'],
        notify  => Service['svc:/application/pkg/server:default'];
    }

    # Create htdocs
    file { '/var/apache2/2.4/repo-htdocs':
      ensure => directory,
      before => Apache::Vhost['repo'],
    }

    # Add a very basic index.html
    file { '/var/apache2/2.4/repo-htdocs/index.html':
      content => "It's a Repo!"
    }

    # Set the host_alias to add the 'repo' host
    host { 'puppet-labs.oracle.lab':
      # Where did ipaddres come from ... facter
      ip           => $::ipaddress,
      host_aliases => ['puppet-lab', 'puppet', 'repo']
    }

    # See Oracle Docs for 'Depot Server Apache Configuration'
    apache::vhost { 'repo':
      docroot               => '/var/apache2/2.4/repo-htdocs',
      redirect_source       => ['/solaris'],
      redirect_dest         => ['http://localhost:8080/solaris/'],
      allow_encoded_slashes => 'nodecode',
      filters               => [
        'FilterDeclare  COMPRESS',
        'FilterProvider COMPRESS DEFLATE "%{Content_Type} = \'text/html\'"',
        'FilterProvider COMPRESS DEFLATE "%{Content_Type} = \'application/javascript\'"',
        'FilterProvider COMPRESS DEFLATE "%{Content_Type} = \'text/css\'"',
        'FilterProvider COMPRESS DEFLATE "%{Content_Type} = \'text/plain\'"',
      ],
      proxy_pass            => [
        {
          'path'     => '/solaris',
          'url'      => 'http://localhost:8080',
          'params'   => {'max'                   => '200'},
          'keywords' => ['nocanon']
        }
      ],

    }

  }

  # basic configuration for webservers
  class lab::webserver {
    service { 'svc:/network/http:apache24':
      ensure                 => running,
    }
    # We have previously installed the puppetlabs-apache module
    # WARNING: Configurations not managed by Puppet will be purged.
    class { 'apache':
      keepalive              => 'on',
      max_keepalive_requests => '10000',
    }

    # View our webserver content
    # links http://localhost -dump
    }

    ############################################
    #### simply defining classes doesn't apply any resources
    #### including the class in the manifest or in a node classification
    #### applies all the resources in the class to that node
    ############################################

    # Set the default node behavior. In conjunction with the base class and no
    # additional nodes this is identical to the previous configurations. i.e. all
    # nodes have the same resources applied
    node default {
      include lab::common
    }

    node /puppet-lab.*/ {
      include lab::common
    }

    node /www.*/ {
      include lab::common
      include lab::webserver
    }
