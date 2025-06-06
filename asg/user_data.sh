#!/bin/bash
set -eux

dnf update -y
dnf install -y nginx
systemctl enable nginx
systemctl start nginx
