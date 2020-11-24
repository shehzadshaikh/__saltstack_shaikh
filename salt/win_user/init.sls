# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "win_user/map.jinja" import user_settings with context -%}

{% set OSFAMILY = salt['grains.get']("os_family") -%}

{% if OSFAMILY == "Windows" %}
addusers_user_local:
  user.present:
    - name: salty
    - groups:
      - Administrators
    - password: "{{ salt['random_complex.get_str'](20) }}"
    - enforce_password: False

{% else %}
addusers_windows_only:
  test.fail_without_changes:
    - name: 'This state is for Windows Only, current OS {{ OSFAMILY }}.'

{% endif %}
