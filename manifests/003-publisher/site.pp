# 003-publisher-site.pp

# Copy zshrc from the lab module instead of using the 'content' parameter
file { '/root/.zshrc':
  ensure => present,
  source => 'puppet:///modules/lab/zshrc';
}

# Configure the publisher for the lab
pkg_publisher { 'solaris':
  #origin      => ['http://pkg.oracle.com/solaris/release/'],
  origin      => ['http://ipkg.us.oracle.com/solaris12/minidev'],
}
