# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "minion/map.jinja" import minion_settings with context %}

copy_minion_bootstrap:
  file.managed:
    - name: {{ minion_settings.config.filename }}
    - source: {{ minion_settings.config.source }}
    - mode: 0744

{# TODO: add naming convention for minion hostname to be updated #}
execute_minion_bootstrap:
  cmd.run:
    - name: |
      "bash {{ minion_settings.config.filename }} \
        -P -X -i $(hostname -s) -A {{ minion_settings.salt_master }} \
        > {{ minion_settings.config.filename }}_$(date +%Y%m%d).output 2>&1"
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
