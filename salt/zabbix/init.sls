# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "zabbix/map.jinja" import zabbix_settings with context -%}

{% set OSFAMILY = salt['grains.get']("os_family") -%}
{% set OSVERSION = salt['grains.get']("osmajorrelease")|int -%}

install_wget_package:
  pkg.installed:
    - name: wget
    - unless:
      - rpm -q wget

create_opt_directory:
  file.directory:
    - name: /opt/zabbix
    - makedirs: true

{% for package in zabbix_settings.agent.pkgs %}
download_{{ package }}_rpm:
  cmd.run:
    - name: |
        wget https://repo.zabbix.com/zabbix/{{ zabbix_settings.agent.version.major }}/rhel/{{ OSVERSION }}/x86_64/{{ package }}-{{ zabbix_settings.agent.version.major }}.{{ zabbix_settings.agent.version.minor }}-1.el{{ OSVERSION }}.x86_64.rpm \
        -o /opt/zabbix/{{ package }}-{{ zabbix_settings.agent.version.major }}.{{ zabbix_settings.agent.version.minor }}-1.el{{ OSVERSION }}.x86_64.rpm
    - create: /opt/zabbix/{{ package }}-{{ zabbix_settings.agent.version.major }}.{{ zabbix_settings.agent.version.minor }}-1.el{{ OSVERSION }}.x86_64.rpm
    - unless:
      - rpm -q {{ package }}-{{ zabbix_settings.agent.version.major }}.{{ zabbix_settings.agent.version.minor }}-1.el{{ OSVERSION }}.x86_64.rpm

install_{{ package }}_rpm:
  pkg.installed:
    - name: {{ package }}
    - enable: true
    - source:
      - {{ package }}: /opt/zabbix/{{ package }}-{{ zabbix_settings.agent.version.major }}.{{ zabbix_settings.agent.version.minor }}-1.el{{ OSVERSION }}.x86_64.rpm
{% endfor %}

copy_zabbix_agent_configs:
  file.managed:
  - name: {{ zabbix_settings.config.filename }}
  - source: {{ zabbix_settings.config.source }}
  - template: jinja
  - backup: minion
  - require:
    - pkg: zabbix-agent

start_zabbix_agent_service:
  service.running:
    - name: {{ zabbix_settings.service.name }}
    - enable: {{ zabbix_settings.service.enable }}
    - require:
      - pkg: zabbix-agent
      - file: copy_zabbix_agent_configs