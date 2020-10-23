# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "firewalld/map.jinja" import firewalld_settings with context %}

{% set OSFAMILY = salt['grains.get']("os_family") %}
{% set OSVERSION = salt['grains.get']("osmajorrelease") %}


{% if OSFAMILY == "RedHat" and OSVERSION == 7 %}

{# Disable iptables service that comes with rhel/centos #}
disable_iptables_service:
  service.disabled:
    - name: iptables
    - enable: False

disable_ip6tables_service:
  service.disabled:
    - name: ip6tables
    - enable: False

install_firewalld_service:
  pkg.installed:
    - name: {{ firewalld_settings.package.name }}
    - version: {{ firewalld_settings.package.version }}

start_firewalld_service:
  service.running:
    - name: {{ firewalld_settings.service.name }}
    - enable: {{ firewalld_settings.service.enable }}
    - require:
      - pkg: install_firewalld_service
      - file: config_firewalld_service
{% else %}

skip_firewalld_installation:
  #test.fail_without_changes:
  test.show_notification:
    - text: |
        "firewalld not supported on {{ OSFAMILY }}-{{ OSVERSION }}"
{% endif %}

