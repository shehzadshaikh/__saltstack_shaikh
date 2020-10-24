# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "selinux/map.jinja" import selinux_settings with context %}

{% set OSFAMILY = salt['grains.get']("os_family") %}

{% if OSFAMILY == "RedHat" %}
install_selinux_exec_modules:
  pkg.installed:
    - pkgs:
      - policycoreutils
      - policycoreutils-python

moidfy_selinux_settings:
  selinux.mode:
    - name: {{ selinux_settings.mode }}
    - require:
      - pkg: install_selinux_exec_modules

persiste_selinux_config:
  file.managed:
    - name: {{ selinux_settings.config.filename }}
    - source: {{ selinux_settings.config.source }}
    - user: root
    - group: root
    - mode: 600
    - template: jinja
{% else %}

skip_firewalld_installation:
  test.show_notification:
    - text: |
        "SELinux not supported on {{ OSFAMILY }}"
{% endif %}
