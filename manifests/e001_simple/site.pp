######
# e001_simple/site.pp
######
$content='
# 001-simple-site.pp
PROMPT="[%F{white}%n%f@%F{white}%m%f(${ret_status}) %F{white}%T%f %l]
<%/>
%F{red}[%h]%f %{$reset_color%}"
'

file { '/root/.zshrc':
  ensure  => present,
  content => $content;
}
