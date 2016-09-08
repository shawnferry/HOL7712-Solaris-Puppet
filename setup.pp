#
# In the lab environment these steps will make very few if any changes,
# we assume puppet has alread been installed via pkg install puppet
#

$lab_homedir = '/root'
$labdir = "${lab_homedir}/HOL7712-Solaris-Puppet"

# Pacakges to mirror
$mirror_pacakges = 'git \
links \
puppetlabs-apache \
editor/vim \
ilb \
rsync'

# This mountpoint changes during the lab
$local_repo_dir='/rpool/repositories'
# Where can we copy packages from initially?
$local_repo_origin='http://ipkg.us.oracle.com/solaris12/minidev/'

# If you need to define proxies here to reach outside resources
# you must also add them to your environemnt to install gems via the
# package provider. The package type doesn't recognize environment
$env = [
  # HOME needs to be defined for Vundle install
  "HOME=${lab_homedir}",
  #'http_proxy=',
  #'https_proxy='
  ]

  # Set for the value for domain so we can be sure what it will be in
  # the lab environment
  service { 'svc:/network/dns/client:default':
    ensure => 'running'
  }
  svccfg { 'svc:/network/dns/client:default/:properties/config/domain':
    ensure => 'present',
    type   => 'astring',
    value  => 'oracle.lab',
    notify => Service['svc:/network/dns/client:default'],
    tag    => ['pre'];
  }

  $packages = [ 'git', 'editor/vim' ]
  package { $packages:
    ensure => present,
    tag    => ['pre'];
  }

  # Install the puppet-lint gem via the package type with the gem provider
  package { 'puppet-lint':
    ensure   => present,
    provider => 'gem',
    tag      => ['pre'];
  }

  # Make puppet-lint available on our path
  file_line { 'ruby_bin_path':
    path => "${lab_homedir}/.profile",
    line => 'export PATH=$PATH:/usr/ruby/2.1/bin';
  }

  # Copy the lab .vimrc to /root
  file {
    "${lab_homedir}/.vimrc":
      ensure => present,
      source => "${labdir}/labfiles/vimrc";

    "${lab_homedir}/.zshrc":
      ensure => present,
      source => "${labdir}/labfiles/zshrc";
  }

  # Copy the lab invalid.pp to /root
  file { "${lab_homedir}/invalid.pp":
    ensure => present,
    source => "${labdir}/labfiles/invalid.pp";
  }

  # Ensure the bundle directory exists
  # There is no -p option we need the parents to exist as well
  file { ["${lab_homedir}/.vim/","${lab_homedir}/.vim/bundle"]:
    ensure => directory;
  }

  # Install Vundle
  # using the vcsrepo module would be better
  exec { 'vundle install':
    command     => "/usr/bin/git clone \
    https://github.com/VundleVim/Vundle.vim.git \
    ${lab_homedir}/.vim/bundle/Vundle.vim",
    creates     => "${lab_homedir}/.vim/bundle/Vundle.vim",
    environment => $env,
    before      => Exec['vundle plugins'],
    tag         => ['pre'];
  }

  # Install Vundle Plugins
  # This is not a good example
  exec { 'vundle plugins':
    command     => '/usr/bin/vim -i NONE -c VundleInstall -c quitall',
    creates     => "${lab_homedir}/.vim/bundle/vim-puppet",
    environment => $env,
    tag         =>  ['pre'];
  }

  # Create the manifests directory
  file { '/etc/puppet/manifests':
    ensure => directory
  }

  # Create a local repository filesystem
  # we will change the mountpoint in the lab
  zfs { 'rpool/repositories':
    ensure => present,
    tag    => ['pre'];
  }

  # Create the repo
  exec { 'Create repo':
    command => "/usr/bin/pkgrepo create ${local_repo_dir}",
    creates => "${local_repo_dir}/pkg5.repository",
    require => Zfs['rpool/repositories'],
    tag     => ['pre'];
  }

  # Add the lab publisher
  exec { 'Add Lab Publisher':
    command => "/usr/bin/pkgrepo add-publisher -s ${local_repo_dir} lab",
    creates => "${local_repo_dir}/publisher/lab",
    require => Exec['Create repo'],
    tag     => ['pre'];
  }

  exec { 'Recv packages':
    command => "/usr/bin/pkgrecv \
    -d ${local_repo_dir}/publisher/lab \
    -m latest \
    -s ${local_repo_origin} \
    ${mirror_pacakges}
    ",
    unless => "/usr/bin/pkgrepo list -s file:///${local_repo_dir}/publisher/lab \
      ${mirror_pacakges} > /dev/null 2>&1",
    require => Exec['Add Lab Publisher'],
    tag     => ['pre'];
  }

  # Copy basic hiera data files
  file {
    '/var/lib/hiera/defaults.yaml':
    source => "${labdir}/labfiles/hiera/defaults.yaml";

    '/var/lib/hiera/global.yaml':
    source => "${labdir}/labfiles/hiera/global.yaml"
  }
