# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "rsyslog/map.jinja" import rsyslog_settings with context %}

install_rsyslog_service:
  pkg.installed:
    - name: {{ rsyslog_settings.package.name }}

configure_rsyslog_service:
  file.managed:
    - name: {{ rsyslog_settings.configs.filename }}
    - source: {{ rsyslog_settings.configs.source }}
    - user: root
    - group: root
    - template: jinja

start_rsyslog_service:
  service.running:
    - name: {{ rsyslog_settings.service.name }}
    - enable: {{ rsyslog_settings.service.enable }}
    - require:
      - pkg: install_rsyslog_service
    - watch:
      - file: configure_rsyslog_service

rsyslog_workdirectory:
  file.directory:
    - name: {{ rsyslog_settings.configs.workdirectory }}
    - user: {{ rsyslog_settings.runuser }}
    - group: {{ rsyslog_settings.rungroup }}
    - mode: 755
    - makedirs: True

{% for filename in rsyslog_settings.custom_configs %}
rsyslog_custom_{{filename}}:
  file.managed:
    - name: /etc/rsyslog.d/{{ filename }}
    - source: salt://rsyslog/files/{{ filename }}
    - watch_in:
      - service: {{ rsyslog_settings.service }}
{% endfor %}
