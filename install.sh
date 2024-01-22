#!/bin/sh
set -eux -o pipefail

mkdir -p /build/dist
chmod og+w /build/dist

cp -p auto.start /etc/local.d/99-auto.start
chown root:root /etc/local.d/99-auto.start

cp -p watched /opt/bin/watched
chown root:root /opt/bin/watched
cp -p watched.init /etc/init.d/watched
chown root:root /etc/init.d/watched

cp -p synced /opt/bin/synced
chown root:root /opt/bin/synced
cp -p synced.init /etc/init.d/synced
chown root:root /etc/init.d/synced

cp -p service.example /etc/init.d/service.example
chown root:root /etc/init.d/service.example
