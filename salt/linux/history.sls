# -*- coding: utf-8 -*-
# vim: ft=sls

{%- from "linux/map.jinja" import linux_setting with context %}

{%- if linux_setting.history.enable %}
configure_bash_history:
  file.managed:
    - name: {{ linux_setting.history.filename }}
    - source: {{ linux_setting.history.source }}
    - user: root
    - group: root
    - mode: 644
    - template: jinja
{%- endif %}

