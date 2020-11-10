# -*- coding: utf-8 -*-
# vim: ft=sls

{% from 'swap/map.jinja' import swap_settings with context %}


{% set OSVERSION = salt['grains.get']("osmajorrelease") %}
{% set OSFAMILY = salt['grains.get']("os_family") %}

{% if OSFAMILY == "RedHat" -%}
{%   if OSVERSION == 6 %}
community_swap_file:
  cmd.run:
    - name: |
        [ -f /.swapfile ] || dd if=/dev/zero of=/.swapfile bs=1M count={{ }}
        chmod 0600 /.swapfile
        mkswap /.swapfile
        echo '/.swapfile      none      swap     sw       0       0' >> /etc/fstab
        swapon -a
    - unless: file /.swapfile 2>&1 | grep -q "Linux/i386 swap"

{# this only works for XFS; can't use fallocate command OR dd for a swap file on XFS due to "holes in file" #}
swapon_create_swapfile: 
  cmd.run:
    - name: /sbin/xfs_mkfile -p {{ extraswap }}g {{ swapdir }}/swapfile
    - creates: {{ swapdir }}/swapfile

swapon_mode_swapfile:
  file.managed:
    - name: {{ swapdir }}/swapfile
    - mode: 600

swapon_setup_swapfile:
  cmd.run:
    - name: /sbin/mkswap {{ swapdir }}/swapfile
    - unless: /sbin/swapon -s | /bin/grep '{{ swapdir }}/swapfile'

swapon_mount_swapfile:
  mount.swap:
    - name: {{ swapdir }}/swapfile

{% else %}
skip_non_rhel_os:
  test.show_notification:
    - text: |
        "Non-RHEL OS not supported, OS family is {{ OSFAMILY }}."
{% endif %}