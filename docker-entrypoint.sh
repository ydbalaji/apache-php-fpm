#!/bin/bash
set -ex

/usr/bin/supervisord -nc /etc/supervisor/conf.d/supervisord.conf