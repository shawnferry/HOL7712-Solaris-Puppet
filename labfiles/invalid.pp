# Taking advantage of puppet-lint and syntastic
# This file is intentionally invalid

# This package definition is missing the : after the pacakge name
# Which breaks parsing of this manifest as a whole.
# puppet parser

# Add the missing : and write the file
package { 'git'
ensure => present;
}

# puppet-lint also emits warnings for the puppet style guide
# After you fix the unparsable syntax error you will get a warning.
exec { 'foo':
  foo => 'bar',
  baz => 'quux',
  other_foo_var => 'error',
  # Add another variable here
  ;
}
