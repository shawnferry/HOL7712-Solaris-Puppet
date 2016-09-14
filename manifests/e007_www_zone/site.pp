######
# e007_www_zone/site.pp
######

class 'lab::www_zone01' {
	zone { 'www-kz01':
		 ensure         => 'running',
		 zonecfg_export => 'puppet:///modules/lab/zones/www-kz.zcfg',
		 config_profile => 'puppet:///modules/lab/zones/www-kz01.xml'
	}
}

# Apply this class to the www node classification as
# include 'lab::www_zone01'
