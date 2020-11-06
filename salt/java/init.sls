# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "java/map.jinja" import java_settings with context %}

{% set OSFAMILY = salt['grains.get']('os_family') %}

{% if OSFAMILY == "RedHat" %}
java_install_package:
  pkg.installed:
    - name: {{ java_settings.common.package }}
    - version: {{ java_settings.common.version }}
    - refresh: true

java_env_var_config:
  file.managed:
    - name: {{ java_settings.config.path }}
    - source: {{ java_settings.config.source }}
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - clean: {{ java_settings.config.clean }}
    - onlyif:
      - rpm -q java

{% else %}
non_rhel_notification:
  test.show_notification:
    - text: |
        "Java installtion not supported on non-RHEL OS, {{ OSFAMILY }}."
{% endif %}
