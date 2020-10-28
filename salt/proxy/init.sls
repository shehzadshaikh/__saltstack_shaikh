# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "proxy/map.jinja" import proxy_settings with context %}

configure_proxy_yum:
  file.managed:
    - name: {{ proxy_settings.config.yum.filename }}
    - source: {{ proxy_settings.config.yum.source }}
    - user: root
    - group: root
    - mode: 644
    - template: jinja

configure_proxy_others:
  file.managed:
    - name: {{ proxy_settings.config.other.filename }}
    - source: {{ proxy_settings.config.other.source }}
    - user: root
    - group: root
    - mode: 644
    - template: jinja
