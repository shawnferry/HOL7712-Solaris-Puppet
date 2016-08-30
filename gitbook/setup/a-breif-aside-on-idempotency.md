# Puppet is \(should be\) Idempotent

When you are executing puppet manifests nothing should change on repeated runs of the agent or application of the manifest.

![](/gitbook/images/SETUP-007-idempotent.png)

## Why was there a change just now?

When you applied setup.pp why was there a change the second time but not the third or Nth time? If you updated invalid.pp in the previous steps it will have been overwritten with the original file content.

After the system is in the state described in the setup.pp manifest additional manifest applications will not change anything.

## Where isn't Puppet Idempotent?

If you write your manifests correctly, puppet is always idempotent. If you are using the exec type look to the creates and unless parameters to keep puppet from _making changes_ on every manifest application.

### This resource will make changes until the Vundle.vim directory is created

```ruby

exec { 'vundle install':

command     => "/usr/bin/git clone \

  https://github.com/VundleVim/Vundle.vim.git \

  ${lab_homedir}/.vim/bundle/Vundle.vim",

creates     => "${lab_homedir}/.vim/bundle/Vundle.vim",

environment => $env,

before      => Exec['vundle plugins'];

}

```

### This resource will report a _change_ on every execution

```ruby

exec { 'foo':

  command => 'touch /tmp/foo'

}

```

## Why should you care?

For now,  you don't care. You can however apply manifests as many times as you want and it shouldn't make changes after the system is in the expected state.

Later when you are managing your multi-server environment you will be seeing reports of changes being made on every run.

See also: [Introduction to Puppet](https://docs.puppet.com/guides/introduction.html) and [Puppet Type Reference](https://docs.puppet.com/puppet/latest/reference/type.html)

