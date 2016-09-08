#
# Reverse some setup.pp steps so it does something in the lab
#

$lab_homedir = '/root'
$labdir = "${lab_homedir}/HOL7712-Solaris-Puppet"

  # Make puppet-lint available on our path
  file_line { 'ruby_bin_path':
    ensure => absent,
    path   => "${lab_homedir}/.profile",
    line   => 'export PATH=$PATH:/usr/ruby/2.1/bin';
  }

  # Copy the lab .vimrc to /root
  file {
    "${lab_homedir}/.vimrc":
      ensure => absent,
      source => "${labdir}/labfiles/vimrc";

    "${lab_homedir}/.zshrc":
      ensure => absent,
      source => "${labdir}/labfiles/zshrc";
  }

  # Copy the lab invalid.pp to /root
  file { "${lab_homedir}/invalid.pp":
    ensure => absent,
    source => "${labdir}/labfiles/invalid.pp";
  }

  # Create the manifests directory
  file { '/etc/puppet/manifests':
    ensure => absent
  }

  # Copy basic hiera data files
  file {
    '/var/lib/hiera/defaults.yaml':
    ensure => absent;
  }
