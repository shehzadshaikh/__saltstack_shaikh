# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "proxy/map.jinja" import proxy_settings with context %}

configure_firewalld_service:
  file.managed:
    - name: {{ proxy_settings.config.filename }}
    - source: {{ proxy_settings.config.source }}
    - user: root
    - group: root
    - mode: 644
    - template: jinja

{# TODO: proxy setting environment variable #}