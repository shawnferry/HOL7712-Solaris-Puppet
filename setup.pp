#
# In the lab environment these steps will make very few if any changes,
# we assume puppet has alread been installed via pkg install puppet
#

# Install additional packages

$lab_homedir = '/root'
$labdir = "${lab_homedir}/HOL7712-Solaris-Puppet"

# If you need to define proxies here to reach outside resources
# you must also add them to your environemnt to install gems via the
# package provider. The package type doesn't recognize environment
$environment = [
  # HOME needs to be defined for Vundle install
  "HOME=${lab_homedir}",
  #'http_proxy=',
  #'https_proxy='
]

$packages = [ 'git', 'editor/vim' ]
package { $packages:
  ensure => present
}

# Install the puppet-lint gem via the package type with the gem provider
package { 'puppet-lint':
  ensure   => present,
  provider => 'gem';
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

# Copy the lab .vimrc to /root
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
  environment => $environment,
  before      => Exec['vundle plugins'];
}

# Install Vundle Plugins
# This is not a good example
exec { 'vundle plugins':
  command     => '/usr/bin/vim -i NONE -c VundleInstall -c quitall',
  creates     => "${lab_homedir}/.vim/bundle/vim-puppet",
  environment => $environment;
}

# Create the manifests directory
file { '/etc/puppet/manifests':
  ensure => directory
}
