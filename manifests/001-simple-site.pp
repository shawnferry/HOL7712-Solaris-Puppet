# 001-simple-site.pp
$content='
# simple-site.pp
PROMPT="[%F{white}%n%f@%F{white}%m%f(${ret_status}) %F{white}%T%f %l]
<%/>
%F{red}[%h]%f %{$reset_color%}"

# $1 = type; 0 - both, 1 - tab, 2 - title
# rest = text
setTerminalText () {
    # echo works in bash & zsh
    local mode=$1 ; shift
    echo -ne "\033]$mode;$@\007"
}
stt_both  () { setTerminalText 0 $@; }
stt_tab   () { setTerminalText 1 $@; }
stt_title () { setTerminalText 2 $@; }
'

file { '/root/.zshrc':
  ensure  => present,
  content => $content;
}
