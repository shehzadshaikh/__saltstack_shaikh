# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "std_tools/map.jinja" import std_tools_settings with context %}

{% set OSFAMILY = salt['grains.get']("os_family") %}
{% set OSVERSION = salt['grains.get']("osmajorrelease") %}

{% if OSFAMILY == "RedHat" %}
{% if OSVERSION == 7 %}
{% for pkg in std_tools_settings.packages.rhel7 %}
install_std_tools_{{ pkg }}:
  pkg.installed:
    - name: {{ pkg }}
{% endfor %}
{% elif OSVERSION == 6 %}
{% for pkg in std_tools_settings.packages.rhel6 %}
install_std_tools_{{ pkg }}:
  pkg.installed:
    - name: {{ pkg }}
{% endfor %}
{% endif %}
{% else %}

skip_std_tools_installation:
  test.show_notification:
    - text: |
        "Standard tool installation skipped for non-RHEL OS, current OS {{ OSFAMILY }}"
{% endif %}
