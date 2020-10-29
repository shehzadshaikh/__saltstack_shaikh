# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "zabbix/map.jinja" import zabbix_settings with context -%}

{% set OSFAMILY = salt['grains.get']("os_family") -%}
{% set OSVERSION = salt['grains.get']("osmajorrelease")|int -%}


{% if OSFAMILY == "RedHat" and OSVERSION >= 6 %}
{%- if zabbix_settings.version_repo|float > 3.0 %}
{%-   set GPGKEY = 'https://repo.zabbix.com/RPM-GPG-KEY-ZABBIX-A14FE591' %}
{%- else %}
{%-   set GPGKEY = 'https://repo.zabbix.com/RPM-GPG-KEY-ZABBIX-79EA5ED4' %}
{%- endif %}

zabbix_agent_repo:
  pkgrepo.managed:
    - name: zabbix
    - humanname: Zabbix Official Repository - $basearch
    - baseurl: http://repo.zabbix.com/zabbix/{{ zabbix_settings.version_repo }}/rhel/{{ grains['osmajorrelease']|int }}/$basearch/
    - gpgcheck: 1
    - gpgkey: {{ GPGKEY }}

zabbix_agent_non_supported_repo:
  pkgrepo.managed:
    - name: zabbix-non-supported
    - humanname: Zabbix Official Repository non-supported - $basearch
    - baseurl: http://repo.zabbix.com/non-supported/rhel/{{ grains['osmajorrelease']|int }}/$basearch/
    - gpgcheck: 1
    - gpgkey: https://repo.zabbix.com/RPM-GPG-KEY-ZABBIX-79EA5ED4

{%- else %}
non_supported_os_family:
  test.show_notification:
    - text: |
        "Detected OS not supported - {{ OSFAMILY }}-{{ OSVERSION }}"
{%- endif %}
