# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "sshd/map.jinja" import sshd_settings with context %}

configure_sshd_service:
  file.managed:
    - name: {{ sshd_settings.config.filenam }}
    - source: {{ sshd_settings.config.source }}
    - template: jinja

start_sshd_service:
  service.running:
    - name: sshd
    - enable: true
    - watch:
      - file: configure_sshd_service
