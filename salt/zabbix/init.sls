# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "zabbix/map.jinja" import zabbix_settings with context -%}

{% set OSFAMILY = salt['grains.get']("os_family") -%}
{% set OSVERSION = salt['grains.get']("osmajorrelease")|int -%}


{% for package in zabbix_settings.pkgs %}
download_zabbix_agent_rpm:
  file.managed:
    - name: /opt/zabbix/{{ package }}-{{ zabbix_settings.agent.version.minor }}-1.el7.x86_64.rpm
    - source: https://repo.zabbix.com/zabbix/{{ zabbix_settings.agent.version.major }}/rhel/{{ OSVERSION }}/x86_64/{{ package }}-{{ zabbix_settings.agent.version.minor }}-1.el{{ OSVERSION }}.x86_64.rpm
    - user: root
    - group: root
    - mkdirs: true
{% endfor %}

