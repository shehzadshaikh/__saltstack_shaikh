# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "linux/map.jinja" import linux_setting with context %}

install_pam_pkg:
  pkg.installed:
    - name: {{ linux_setting.limits.pkgs.rhel }}

configu_limit_file:
  file.managed:
    - name: /etc/security/limits.conf
    - source: salt://limits/files/limits.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - require:
      - pkg: {{ linux_setting.limits.pkgs.rhel }}
