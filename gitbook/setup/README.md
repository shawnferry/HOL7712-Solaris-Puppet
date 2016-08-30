# Setup

Due to constraints on time and variability present in the physical lab setup pre-work has been completed on the lab VMs. The steps in this chapter will perform the same pre-work in a fresh VM.

During the hands on lab we will still perform the listed steps. However, the execution will be shortened.

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

