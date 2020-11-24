# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "win_firewall/map.jinja" import firewall_settings with context -%}

{% set OSFAMILY = salt['grains.get']("os_family") -%}

{% if OSFAMILY == "Windows" %}
{% for port in firewall_settings.traffic.ingress.allowed %}
firewall_enable_{{ port }}_rule:
  win_firewall.add_rule:
    - name: Allow incoming {{ port }}
    - protocol: {{ port }}
    - action: allow
    - dir: in
    - localport: 1
    - remoteip: any

{% endfor %}
{% else %}
firewall_enable_windows_only:
  test.fail_without_changes:
    - name: 'This state is for Windows Only, os_family is {{os_family}}'

{% endif %}
