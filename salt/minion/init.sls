# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "minion/map.jinja" import minion_settings with context %}
{% set minion_id = salt['cmd.run']("hostname -f") %}

copy_minion_bootstrap:
  file.managed:
    - name: {{ minion_settings.config.filename }}
    - source: {{ minion_settings.config.source }}
    - mode: 0744

{# TODO: 
 # Add naming convention for minion hostname to be updated 
 # Condition to check if minions already installed
 # Restart minion service if minion id or master details changed
 #}
execute_minion_bootstrap:
  cmd.run:
    - name: |
        "bash {{ minion_settings.config.filename }} \
          -P -X -i {{ minion_id }} -A {{ minion_settings.salt_master }} \
          > {{ minion_settings.config.filename }}.output 2>&1"
    - require:
      - file: {{ minion_settings.config.filename }}

start_minion_service:
  service.running:
    - name: {{ minion_settings.service.name }}
    - enable: {{ minion_settings.service.enable }}
    - onlyif:
      - rpm -q salt-minion

clean_minion_bootstrap:
  file.absent:
    - name: {{ minion_settings.config.filename }}
{% endif %}
