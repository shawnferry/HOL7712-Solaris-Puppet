# 002-better/site.pp

# Copy zshrc from the lab module instead of using the 'content' parameter
file { '/root/.zshrc':
  ensure => present,
  owner  => 'root',
  group  => 'root',
  source => 'puppet:///modules/lab/zshrc';
}
