#!/bin/bash
set -e
/usr/bin/kube-context

exec "$@"
