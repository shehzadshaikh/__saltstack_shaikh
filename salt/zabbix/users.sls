# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "zabbix/map.jinja" import zabbix_settings with context -%}

create_zabbix_agent_user:
  user.present:
    - name: {{ zabbix_settings.user }}
    - group: 
      - {{ zabbix_settings.group }}
    - createhome: False                # Home directory should be created by pkg scripts
    - shell: {{ zabbix_settings.shell }}
    - system: True
    - require:
      - group: create_zabbix_agent_group

create_zabbix_agent_group:
  group.present:
    - name: {{ zabbix_settings.group }}
    - system: True
