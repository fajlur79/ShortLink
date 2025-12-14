#!/bin/bash

cat <<'TERMINFO_EOT' > /tmp/foot.terminfo
${foot_terminfo}
TERMINFO_EOT
export TERM=xterm

/usr/bin/tic -x /tmp/foot.terminfo 
              
/usr/bin/infocmp foot > /var/log/foot_terminfo_check.log 2>&1
