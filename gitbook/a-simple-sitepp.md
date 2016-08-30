# Creating a very simple site.pp

In the Adding an Agent section we observed a difference in the prompts between the two systems. We will use puppet to distribute a .dotfile to all it's agents.

## Copy the manifest to \/etc\/puppet\/manifests\/site.pp

1. Even though this is a simple manifest it is not especially easy to type. We will copy it for this first example.
  `cp /root/HOL7712-Solaris-Puppet/manifests/001-simple-site.pp /etc/puppet/manifests/site.pp`


## Execute the agent on WWW server 

1. With site.pp on the master running the agent will compile the catalog and apply the desired changes.
  `puppet apply -t`

## Execute puppet agent on the puppet master

1. With site.pp on the master running the agent will compile the catalog and apply the desired changes.

  When puppet is executed on the master it is also using site.pp. The content of .zshrc in site.pp does not exactly match the content of file copied by setup.pp.
  `puppet apply -t`

## Exec zsh to get the new prompt

1. Now that we have created a \/root\/.zshrc run zsh
  `exec zsh`

## Edit \/etc\/puppet\/manifests\/site.pp on the master

1. Wait you said this was simple! Puppet lint shows you an error about variables in sigle quoted strings! The example in 001-simple-site.pp uses the `content` parameter to the file type.  It is technically simple but it isn't a very good implementation.

# Simplyfying site.pp by using a module to distribute a file

Writing detailed modules is beyond the scope of this lab. However, we will be utilizing a stub of a module to take advantage of puppet's [file serving capabilities](https://docs.puppet.com/puppet/latest/reference/modules_fundamentals.html#files). Puppet provides the ability to access files from the special path puppet:\/\/\/modules\/&lt;module&gt;\/&lt;filename&gt;. We will use this method to truly simplify the example.

In normal use you might generate a module with `puppet module generate <module-name>`and use that module to store all your custom manifests. We will instead create only a subset of the module contents for these steps.

## Create the partial module directory structure

1. We are creating the minimum viable path to achieve this step
  `mkdir -p /etc/puppet/modules/lab/files`

## Copy zshrc to the module's files directory

1. This will make the file available to agents via the puppet file server at puppet:\/\/\/modules\/lab\/zshrc
  `cp /root/HOL7712-Solaris-Puppet/labfiles/zshrc /etc/puppet/modules/lab/files`

## Update site.pp to copy the file

1. We will be removing the `$content` definition and `content` parameter and replacing them with a `source` parameter.


## Execute puppet agent on the node

1. When you apply puppet now there will be a change to .zshrc, the file we are copying from is slightly different than the one inlined in 001-simple-site.pp.
  `puppet apply -t`




