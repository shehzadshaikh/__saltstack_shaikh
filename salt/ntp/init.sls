# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "ntp/map.jinja" import ntp_settings with context %}

include:
  - proxy

install_ntp_service:
  pkg.installed:
    - name: {{ ntp_settings.package.name }}

configure_ntp_service:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - name: {{ ntp_settings.config.filename }}
    - source: {{ ntp_settings.config.source }}
    - template: jinja

start_ntp_service:
  service.running:
    - name: {{ ntp_settings.service.name }}
    - enable: {{ ntp_settings.service.enable }}
    - watch:
      - pkg: install_ntp_service
      - file: configure_ntp_service

disable_chrony_service:
  service.dead:
    - name: chronyd
    - enable: false
    - onlyif:
      - rpm -q chrony
