# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "sshd/map.jinja" import sshd_settings with context %}

configure_sshd_file:
  file.managed:
    - name: {{ sshd_settings.config.filenam }}
    - source: {{ sshd_settings.config.source }}
    - template: jinja

start_sshd_service:
  service.running:
    - name: {{ sshd_settings.service.name }}
    - enable: {{ sshd_settings.service.enable }}
    - watch:
      - file: configure_sshd_file
