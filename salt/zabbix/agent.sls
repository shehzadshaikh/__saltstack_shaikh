# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "zabbix/map.jinja" import zabbix_settings with context -%}

{% set settings = salt['pillar.get']('zabbix-agent', {}) -%}
{% set defaults = zabbix.get('agent', {}) -%}
{% if salt['grains.get']('os') != 'Windows' %}
include:
  - zabbix.users
{% endif %}

install_zabbix_agent:
  pkg.installed:
    - pkgs:
      {%- for name in zabbix.agent.pkgs %}
      - {{ name }}{% if zabbix.agent.version is defined and 'zabbix' in name %}: '{{ zabbix.agent.version }}'{% endif %}
      {%- endfor %}
{% if salt['grains.get']('os') != 'Windows' %}
    - require_in:
      - user: zabbix-formula_zabbix_user
      - group: zabbix-formula_zabbix_group
{% endif %}
  service.running:
    - name: {{ zabbix.agent.service }}
    - enable: True
    - require:
      - pkg: zabbix-agent
      - file: zabbix-agent-logdir
{% if salt['grains.get']('os') != 'Windows' %}
      - file: zabbix-agent-piddir
{% endif %}