######
# e004_webserver/site.pp
######

# Install links character based browser
package { 'web/browser/links': ensure => present }

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

