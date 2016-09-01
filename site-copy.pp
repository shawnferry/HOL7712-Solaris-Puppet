$labfiles  ='/root/HOL7712-Solaris-Puppet'
$manifests ="${labfiles}/manifests"

# Ensure rsync is installed. This uses the
# puppetlabs-rsync module
class { 'rsync': package_ensure => present }

# Set default parameters for Rsync::Get
Rsync::Get {
      recursive => true,
      path      => '/etc/puppet/manifests'
}

# Copy the set of manifests to /etc/puppet/manifests
# without a tag supplied via --tags all resources will be executed
# You probably don't want to do that but nothing is preventing you from doing
# it

rsync::get {
  '001-simple': source => "${manifests}/001-simple/";
  '002-better': source => "${manifests}/002-better/";
  '003-publisher': source => "${manifests}/003-publisher/";
  '004-nodes': source => "${manifests}/004-nodes/";
  '005-webserver': source => "${manifests}/005-webserver/";
}
