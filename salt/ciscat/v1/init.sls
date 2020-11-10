# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "ciscat/v1/map.jinja" import ciscat_settings with context %}

{% set OSFAMILY = salt['grains.item']('os_family') %}
{% set OSVERSION = salt['grains.item']('osmajorrelease') %}

{# #}
{% for package in ciscat_settings.configs.remove_pkgs|default(['na']) -%}
ciscat_remove_{{ package }}:
  pkg.removed:
    - name: {{ package }}
{% endfor -%}

{# #}
{% for package in ciscat_settings.configs.install_pkgs -%}
ciscat_install_{{ package }}:
  pkg.installed:
    - name: {{ package }}
    - value: 1
{% endfor -%}

{# #}
{% for sysctlv in ciscat_settings.configs.sysctl_disable|default(['na']) %}
ciscat_sysctl_disable_{{sysctlv}}:
  sysctl.present:
    - name: {{ sysctlv }}
    - value: 0
{% endfor %}

{# #}
{% if ciscat_settings.configs.rsyslog|default(True) %}
ciscat_install_rsyslog_pkg:
  pkg.installed:
    - name: rsyslog

ciscat_enable_rsyslog_service:
  service.running:
    - name: rsyslog
    - enable: True
    - require:
      - pkg: ciscat_install_rsyslog_pkg
{# 
 # Ensure rsyslog default file permissions configured
 # https://secscan.acron.pl/centos7/4/2/1/3
 #}
csicat_rsyslog_fielcreatemode:
  file.append:
    - name: /etc/rsyslog.conf
    - text: '$FileCreateMode 0640'
{% endif %}

# 4.2.4 Ensure permissions on all logfiles are configured
{% if ciscat_settings.configs.log_files_perm| default(True) %}
  {% if salt['cmd.run']('find /var/log -type f -perm /o=rwx,g=wx') %}
ciscat_var_log_perm:
  cmd.run:
    - name: 'find /var/log -type f -exec chmod g-wx,o-rwx {} +'
  {% endif %}
{% endif %}

# 5.1.2 Ensure permissions on /etc/crontab file are configured
{% if ciscat_settings.configs.cron_perm| default(True) %}
ciscat_crontab_perm:
  file.managed:
    - name: '/etc/crontab'
    - mode: 600
    - user: root
    - group: root
    - replace: False
{% endif %}

#5.1.2 - 5.17 Ensure permissions on /etc/cron.* folder are configured
{% for directory in ciscat_settings.configs.cron_dirs %}
std_ciscat_cron_permsissions_{{ directory }}:
  file.directory:
    - name: {{ directory }}
    - mode: 600
    - user: root
    - group: root
{% endfor %}

{% if ciscat_settings.configs.ensure_core_dumps|default(True) %}
ciscat_core_dumps_limits:
  file.append:
    - name: /etc/security/limits.d/core_limits.conf
    - text: '* hard core 0'
{% endif %}

{% if ciscat_settings.aide| default(True) %}
csicat_aide_cron:
  cron.present:
    - name: /usr/sbin/aide --check" | tee -a /var/spool/cron/root
    - user: root
    - special: '@daily'
{% endif %}

{% if OSVERSION == 7 and ciscat_settings.configs.grub2.update|default(True) -%}
  {% for grub_setting in ciscat_settings.configs.grub2.grub_settings -%}
ciscat_grub2_settings_{{ grub_setting }}:
  file.line:
    - name: {{ ciscat_settings.configs.grub2.config_file }}
    - match: '{{ grub_setting }}=*.'
    - content: '{{ grub_setting }}={{ ciscat_settings.configs.grub2.grub_settings[grub_setting] }}'
    - mode: replace
  {% endfor -%}

ciscat_grub_invalidate:
  cmd.run:
    - name: {{ ciscat_settings.configs.grub2.grub_post }}
    - onchanges: 
      - file: {{ ciscat_settings.configs.grub2.config_file }}

ciscat_grub_invalidate_secure:
  file.managed:
    - name: {{ ciscat_settings.configs.grub2.config_file }}
    - mode: 600
    - user: root
    - group: root
{% endif -%}
