# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "zabbix/map.jinja" import zabbix_settings with context -%}

include:
  - {{ slspath }}/users

{% for package in zabbix_settings.agent.pkg %}
install_{{ package }}:
  pkg.installed:
    - name: {{ package }}
    - require_in:
      - user: create_zabbix_agent_user
      - group: create_zabbix_agent_group
{% endfor %}

start_zabbix_agent_service:
  service.running:
    - name: {{ zabbix_settings.service.name }}
    - enable: {{ zabbix_settings.service.enable }}
    - require:
      - pkg: zabbix-agent

zabbix_agent_config:
  file.managed:
  - name: {{ zabbix_settings.config.filename }}
  - source: {{ zabbix_setting.config.source }}
  - template: jinja
  - require:
    - pkg: zabbix-agent

zabbix_agentd.conf.d:
  file.directory:
  - name: /etc/zabbix/zabbix_agentd.conf.d
  - makedirs: true
  - require:
    - pkg: zabbix-agent
