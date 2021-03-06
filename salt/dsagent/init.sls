# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "dsagent/map.jinja" import dsagent_settings with context -%}

{% set OSFAMILY = salt['grains.get']("os_family") -%}
{% set OSVERSION = salt['grains.get']("osmajorrelease")|int -%}

{# REQUIREMENT: 
 # Following packages or states are needed for sucessful state run
 #  1. proxy state
 #  2. unizp package
 #  3. wget package
 #}

create_opt_directory:
  file.directory:
    - name: {{ dsagent_settings.config.rpm }}
    - makedirs: true

{% if OSFAMILY == "RedHat" %}
copy_ds_agent_rpm:
  file.managed:
    {% if OSVERSION == 6 %}
    - name: {{ dsagent_settings.config.rpm }}/{{ dsagent_settings.pkg.rhel6 }}
    - source: {{ dsagent_settings.pkg.source }}/{{ dsagent_settings.pkg.rhel6 }}
    {% elif OSVERSION == 7 %}
    - name: {{ dsagent_settings.config.rpm }}/{{ dsagent_settings.pkg.rhel7 }}
    - source: {{ dsagent_settings.pkg.source }}/{{ dsagent_settings.pkg.rhel7 }}
    {% endif %}
    - require:
      - file: create_opt_directory

install_ds_agent_rpm:
  cmd.run:
    {% if OSVERSION == 6 %}
    - name: |
        rpm -i {{ dsagent_settings.config.rpm }}/{{ dsagent_settings.pkg.rhel6 }}
    {% elif OSVERSION == 7 %}
    - name: |
        rpm -i {{ dsagent_settings.config.rpm }}/{{ dsagent_settings.pkg.rhel7 }}
    {% endif %}
    - unless:
      - rpm -q ds_agent

{% else %}

skip_ds_agent_installation:
  test.show_notification:
    - text: |
        "DS Agent installation currently doesn't support non-RHEL OS, current OS {{ OSFAMILY }}"
{% endif %}

{# TODO: update configuration file and register deep security agent with management console if needed #}

start_ds_agent_service:
  service.running:
    - name: {{ dsagent_settings.service.name }}
    - enable: {{ dsagent_settings.service.enable }}
    - onlyif:
      - rpm -q ds_agent
