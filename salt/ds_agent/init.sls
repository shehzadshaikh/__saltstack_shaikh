# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "dsagent/map.jinja" import dsagent_settings with context -%}

{% set OSFAMILY = salt['grains.get']("os_family") -%}
{% set OSVERSION = salt['grains.get']("osmajorrelease")|int -%}
{% set REPO_URL = "https://files.trendmicro.com/products/deepsecurity/en/" %}

{% for pkg in ['wget', 'unzip']%}
install_{{ pkg }}_package:
  pkg.installed:
    - name: {{ pkg }}
    - unless:
      - rpm -q {{ pkg }}
{% endfor $}

create_opt_directory:
  file.directory:
    - name: /opt/ds_agent
    - makedirs: true

{% for package in zabbix_settings.agent.pkgs %}
download_{{ package }}_rpm:
  cmd.run:
    - name: |
        wget {{ REPO_URL }}/{{ dsagent_settings.agent.version }}/{{ dsagent_settings.pkg.downloadable }}_EL{{ OSVERSION }}-{{ dsagent_settings.agent.version }}
    - name: |
        wget https://repo.zabbix.com/zabbix/{{ zabbix_settings.agent.version.major }}/rhel/{{ OSVERSION }}/x86_64/{{ package }}-{{ zabbix_settings.agent.version.major }}.{{ zabbix_settings.agent.version.minor }}-1.el{{ OSVERSION }}.x86_64.rpm \
        -o /opt/zabbix/{{ package }}-{{ zabbix_settings.agent.version.major }}.{{ zabbix_settings.agent.version.minor }}-1.el{{ OSVERSION }}.x86_64.rpm
    - create: /opt/zabbix/{{ package }}-{{ zabbix_settings.agent.version.major }}.{{ zabbix_settings.agent.version.minor }}-1.el{{ OSVERSION }}.x86_64.rpm
    - unless:
      - rpm -q {{ package }}-{{ zabbix_settings.agent.version.major }}.{{ zabbix_settings.agent.version.minor }}-1.el{{ OSVERSION }}.x86_64.rpm

install_{{ package }}_rpm:
  pkg.installed:
    - name: {{ package }}
    - enable: true
    - source:
      - {{ package }}: /opt/zabbix/{{ package }}-{{ zabbix_settings.agent.version.major }}.{{ zabbix_settings.agent.version.minor }}-1.el{{ OSVERSION }}.x86_64.rpm
{% endfor %}

{# TODO: update configuration file and register deep security agent with management console if needed #}

start_ds_agent_service:
  service.running:
    - name: {{ dsagent_settings.service.name }}
    - enable: {{ dsagent_settings.service.enable }}
    - onlyif:
      - rpm -q ds_agent
