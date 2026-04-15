#!/bin/bash

set -ex

# Initialize
if [[ $1 == init ]]; then

    # # Parse parameters
    # TFP=""  # Default empty two factor passcode
    # shift  # skip `init`
    # while [[ $# -gt 0 ]]; do
    #     key="$1"
    #     case $key in
    #         -u|--username)
    #         USERNAME="$2"
    #         ;;
    #         -p|--password)
    #         PASSWORD="$2"
    #         ;;
    #         -t|--twofactor)
    #         TWOFACTOR="$2"
    #         ;;
    #     esac
    #     shift
    #     shift
    # done

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

    # socat will make the conn appear to come from 127.0.0.1
    # ProtonMail Bridge currently expects that.
    # It also allows us to bind to the real ports :)
    socat TCP-LISTEN:25,fork,reuseaddr  TCP:127.0.0.1:1025,nodelay &
    socat TCP-LISTEN:143,fork,reuseaddr TCP:127.0.0.1:1143,nodelay &

    # Start protonmail
    # Fake a terminal, so it does not quit because of EOF...
    rm -f faketty
    mkfifo faketty
    cat faketty | protonmail-bridge --cli

fi
