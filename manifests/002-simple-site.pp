# 002-simple-site.pp

# Copy zshrc from the lab module instead of using the 'content' parameter
file { '/root/.zshrc':
  ensure => present,
  source => 'puppet:///modules/lab/zshrc';
}
