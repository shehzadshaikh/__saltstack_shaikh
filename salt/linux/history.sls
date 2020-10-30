# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "linux/map.jinja" import linux_settings with context %}

{%- if linux_settings.config.history.enable %}
configure_bash_history:
  file.managed:
    - name: {{ linux_settings.config.history.filename }}
    - source: {{ linux_settings.config.history.source }}
    - user: root
    - group: root
    - mode: 644
    - template: jinja
{%- endif %}
