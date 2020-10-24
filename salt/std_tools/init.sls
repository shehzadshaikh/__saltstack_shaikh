# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "std_tools/map.jinja" import std_tools_settings with context %}

{% set OSFAMILY = salt['grains.get']("os_family") %}
{% set OSVERSION = salt['grains.get']("osmajorrelease") %}

{% if OSFAMILY == "RedHat" %}
install_std_tools:
  pkg.installed:
  {% if OSVERSION == 7 %}
    {% for pkg in std_tools_settings.packages.rhel-7 %}
    - pkgs: {{ pkg }}
    {% endfor %}
  {% elif OSVERSION == 6 %}
    {% for pkg in std_tools_settings.packages.rhel-6 %}
    - pkgs: {{ pkg }}
    {% endfor %}
  {% endif %}
{% else %}

skip_std_tools_installation:
  test.show_notification:
    - text: |
        "Standard tool installation skipped for non-RHEL OS, current OS {{ OSFAMILY }}"
{% endif %}
