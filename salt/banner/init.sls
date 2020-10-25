# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "banner/map.jinja" import banner_settings with context %}

{% set OSFAMILY = salt['grains.get']("os_family") %}
{% set OSVERSION = salt['grains.get']("osmajorrelease") %}

{% if OSFAMILY == "RedHat" %}
configure_banner_file:
  file.managed:
    - name: {{ banner_settings.config.filename }}
    - source: {{ banner_settings.config.source }}
    - mode: 644
    - replace: true
    - backup: minion

modify_sshd_config:
  file.blockreplace:
    - name: {{ banner_settings.sshd_config.filename }}
    - marker_start: "# no default banner path"
    {% if OSVERSION == 7 %}
    - marker_end: "# Accept locale-related environment variables"
    {% elif OSVERSION == 6 %}
    - marker_end: "# override default of no subsystems"
    {% endif %}
    - content: Banner {{ banner_settings.config.filename }}
    - append_if_not_found: True
    - backup: '.bkp'
    - show_changes: True

modify_sshd_chiphers:
  file.blockreplace:
    - name: {{ banner_settings.sshd_config.filename }}
    - marker_start: "# Ciphers and keying"
    - marker_end: "#RekeyLimit default none"
    - content: Ciphers aes256-ctr,aes192-ctr,aes128-ctr
    - append_if_not_found: True
    - backup: '.bak'
    - show_changes: True

reload_sshd_service:
  service.running:
    - name: {{ banner_settings.service.name }}
    - enable: {{ banner_settings.service.enable }}
    - reload: {{ banner_settings.service.reload }}
    - watch:
      - file: modify_sshd_config
      - file: modify_sshd_chiphers
{% else %}

skip_banner_non_rhel:
  test.show_notification:
    - text: |
        "Banner state is for RedHat and CentOS OS only, {{ OSFAMILY }} not supported."
{% endif %}
