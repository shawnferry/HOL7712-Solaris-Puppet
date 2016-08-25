#
# In the lab environment these steps will make very few if any changes,
# we assume puppet has alread been installed via pkg install puppet
#

# Install additional packages

$labdir = '/root/HOL7712-Solaris-Puppet'

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
  path => '/root/.profile',
  line => 'export PATH=$PATH:/usr/ruby/2.1/bin';
}

# Copy the lab .vimrc to /root
file { '/root/.vimrc':
  ensure => present,
  source => "${labdir}/labfiles/vimrc";
}

# Copy the lab .vimrc to /root
file { '/root/invalid.pp':
  ensure => present,
  source => "${labdir}/labfiles/invalid.pp";
}

# Ensure the bundle directory exists
file { '/root/.vim/bundle':
  ensure => directory;
}

# Install Vundle
# using the vcsrepo module would be better
exec { 'vundle install':
  command => '/usr/bin/git clone https://github.com/VundleVim/Vundle.vim.git /root/.vim/bundle/Vundle.vim',
  creates => '/root/.vim/bundle/Vundle.vim',
  # Do you need proxies?
  # environment => '';
}

# Install Vundle Plugins
# This is not a good example
exec { 'vundle plugins':
  command => '/usr/bin/vim -i NONE -c VundleInstall -c quitall',
  creates => '/root/.vim/bundle/vim-puppet',
  # Do you need proxies?
  # environment => '';
}

# Create the manifests directory
file { '/etc/puppet/manifests':
  ensure => directory
}
