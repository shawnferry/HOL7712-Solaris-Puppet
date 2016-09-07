# 003-publisher/site.pp

# Copy zshrc from the lab module
file { '/root/.zshrc':
  ensure => present,
  source => 'puppet:///modules/lab/zshrc';
}

# Configure the publisher for the lab
pkg_publisher { 'lab':
  origin      => ['/repositories/publisher/lab'],
}
