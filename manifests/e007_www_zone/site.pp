######
# e007_www_zone/site.pp
######

# Create the zone on all www hosts
node /www.*/ {
  # Copy the zone configuration files
  file {
    "/system/zones/www-zone.zcfg":
    ensure => present,
    source => 'puppet:///modules/lab/zones/www-zone.zcfg';
  "/system/zones/www-zone01.xml":
    ensure => present,
    source => 'puppet:///modules/lab/zones/www-zone01.xml';
  } -> # Files must be copied before they are used
  zone { 'www-zone01':
    ensure         => 'running',
    zonecfg_export => '/system/zones/www-zone.zcfg',
    config_profile => '/system/zones/www-zone01.xml'
  }
}
