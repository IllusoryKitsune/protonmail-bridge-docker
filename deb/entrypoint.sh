#!/bin/bash

set -eu -o pipefail
# Set DEBUG=1 on the container env to trace every command.
[[ "${DEBUG:-0}" == "1" ]] && set -x

cd /protonmail

# Initialize
if [[ "${1:-}" == "init" ]]; then

    # Initialize pass
    gpg --generate-key --batch /protonmail/gpgparams
    pass init pass-key

    # Login
    protonmail-bridge --cli

else

    # Remove stale gpg-agent sockets left over from an unclean shutdown,
    # otherwise the bridge fails to start after a container restart.
    if [ -d /root/.gnupg ]; then
        rm -f /root/.gnupg/S.gpg-agent*
    fi

    # socat will make the conn appear to come from 127.0.0.1 -
    # Proton Mail Bridge currently expects that.
    # It also allows us to bind to the real ports :)
    socat TCP-LISTEN:25,fork,reuseaddr  TCP:127.0.0.1:1025,nodelay &
    socat TCP-LISTEN:143,fork,reuseaddr TCP:127.0.0.1:1143,nodelay &

    # Start protonmail
    # Fake a terminal, so it does not quit because of EOF...
    rm -f /protonmail/faketty
    mkfifo /protonmail/faketty
    cat /protonmail/faketty | protonmail-bridge --cli

fi
