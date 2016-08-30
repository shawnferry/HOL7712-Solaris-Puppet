# Setup

Due to constraints on time and variability present in the physical lab setup pre-work has been completed on the lab VMs. The steps in this chapter will perform the same pre-work in a fresh VM.

During the hands on lab we will still perform the listed steps. However, the execution will be shortened.

### Steps Overview

1. Login to puppet server
2. Install puppet \(done in advance\)
3. Examine HOL7712-Solaris-Puppet\/setup.pp
4. Apply HOL7712-Solaris-Puppet\/setup.pp
5. Examine HOL7712-Solaris-Puppet\/setup.pp
6. Validate invalid.pp manifest
7. Style Check invalid.pp
8. Fix invalid.pp
9. Configure puppet:master and puppet:agent
10. Enable puppet:master and puppet:agent
11. Review puppet.conf
12. Put puppet:agent into maintenance mode
13. Test puppet agent
14. Correct configuration
15. Test puppet agent

**NOTE:**
If you are trying this outside the lab and need proxies. You must export your http\/https\_proxy before trying to install a gem with the gem pacakge provider.

```
$env = [
  # HOME needs to be defined for Vundle install
  "HOME=${lab_homedir}",
  'http_proxy=your.proxy.com:80',
  'https_proxy=your.proxy.com:443'
]
```

