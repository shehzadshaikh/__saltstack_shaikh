# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "ciscat/v1/map.jinja" import ciscat_settings with context %}

{% set OSFAMILY = salt['grains.item']('os_family') %}
{% set OSVERSION = salt['grains.item']('osmajorrelease') %}
{# #}
{% for package in ciscat_settings.configs.remove_pkgs|default(['na']) -%}
  {% if package not in ciscat_settings.configs.remove_pkgs_override|default(['na']) -%}
ciscat_remove_{{ package }}:
  pkg.removed:
    - nmme: {{ package }}
  {% endif -%}
{% endfor -%}

{# #}
{% for package in ciscat_settings.configs.remove_pkgs -%}
  {% if package not in ciscat_settings.configs.remove_pkgs_override|default(['na']) -%}
ciscat_install_{{ package }}:
  pkg.present:
    - nmme: {{ package }}
    - value: 1
  {% endif -%}
{% endfor -%}

{# #}
{% for sysctlv in ciscat_settings.configs.sysctl_disable|default(['na']) %}
  {% if sysctlv not in ciscat_settings.configs.sysctl_disable_override|default(['na']) %}
ciscat_sysctl_disable_{{sysctlv}}:
  sysctl.present:
    - name: {{ sysctlv }}
    - value: 0
  {% endif %}
{% endfor %}}

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

# 4.2.4 Ensure permissions on all logfiles are configured
{% if ciscat_settings.configs.log_files_perm| default(True) %}
  {% if salt['cmd.run']('find /var/log -type f -perm /o=rwx,g=wx') %}
ciscat_var_log_perm:
  cmd.run:
    - name: 'find /var/log -type f -exec chmod g-wx,o-rwx {} +'

# 5.1.2 Ensure permissions on /etc/crontab file are configured
{% if ciscat_settings.configs.cron_perm| default(True) %}
ciscat_crontab_perm:
  file.managed:
    - name: '/etc/crontab'
    - mode: 600
    - user: root
    - group: root
    - replace: False

#5.1.2 - 5.17 Ensure permissions on /etc/cron.* folder are configured
{% for directory in ciscat_settings.configs.configs.cron_dirs %}
std_ciscat_cron_permsissions_{{cf}}:
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

{% if ciscat_settings.configs.tcpwrappers|default(True) %}
ciscat_install_tcp_wrappers:
  pkg.installed:
    - pkgs:
      - tcp_wrappers
{% endif %}

{% if ciscat_settings.aide| default(True) %}
ciscat_install_aide:
  pkg.installed:
    - name: aide 

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

{#
{% if salt['grains.get']('osmajorrelease',0 ) == 6 and  ciscat_settings.grub.update| default(True) %}
## this is only for RHEL 7
#chown root:root /boot/grub2/grub.cfg
#chmod og-rwx /boot/grub2/grub.cfg
{% for grub_setting in ciscat_settings.grub.grub_settings %}
std-ciscat-settings-grub.cfg-{{grub_setting}}:
  file.line:
    - name: {{ciscat_settings.grub.grub_config}}
    - match: '{{grub_setting}}=*.'
    - content: '{{grub_setting}}={{ciscat_settings.grub.grub_settings[grub_setting]}}'
    - mode: replace
{% endfor %}

std-ciscat-grub-post-run-secure:
  file.managed:
    - name: {{ciscat_settings.grub.grub_config}}
    - mode: 600
    - user: root
    - group: root

{% endif %}



{% for fsname in ciscat_settings.disable_filesystem| default(['na']) %}
{% if fsname not in ciscat_settings.disable_filesystem_override| default(['ma']) %}
std_disable_unused_filesystems_ciscat_accumulated_{{fsname}}:
  file.accumulated:
    - name: std_ciscat_accumulator_comment
    - filename: /etc/modprobe.d/CISCAT.conf
    - text: 'install {{fsname}} /bin/true'
    - require_in:
        - file: std_disable_unused_filesystems_deploy_modprod_d_ciscat_conf

{% endif %}
{% endfor %}

# create config file , placing the acumulator data in it
std_disable_unused_filesystems_deploy_modprod_d_ciscat_conf:
  file.managed:
    - name: /etc/modprobe.d/CISCAT.conf
    - source: salt://standardconf/linux/files/CISCAT.conf
    - mode: 600
    - template: jinja


{% if ciscat_settings.etc_issue| default(True) %}
std_ciscat_etc_issue_setup:
  file.managed:
    - name: /etc/issue
    - source: salt://standardconf/linux/files/issue
    - mode: 644
    - user: root
    - group: root

std_ciscat_etc_issue_setup_log:
  logfile.write:
    - name: {{logfile}}
    - data: 'changing /etc/issue'
    - state_name: '{{sls}}'
    - onchanges:
      - file: std_ciscat_etc_issue_setup

{% endif %}


{% if ciscat_settings.etc_issue_net| default(True) %}
std_ciscat_etc_issue_net_setup:
  file.managed:
    - name: /etc/issue.net
    - source: salt://standardconf/linux/files/issue
    - mode: 644
    - user: root
    - group: root

std_ciscat_etc_issue_net_setup_log:
  logfile.write:
    - name: {{logfile}}
    - data: 'changing /etc/issue.net'
    - state_name: '{{sls}}'
    - onchanges:
      - file: std_ciscat_etc_issue_net_setup

{% endif %}

{% if ciscat_settings.banner_net| default(True) %}
std_ciscat_etc_banner_net_setup:
  file.managed:
    - name: /etc/banner.net
    - source: salt://standardconf/linux/files/banner.net
    - mode: 644
    - user: root
    - group: root

std_ciscat_etc_banner_net_setup_log:
  logfile.write:
    - name: {{logfile}}
    - data: 'changing /etc/banner.net'
    - state_name: '{{sls}}'
    - onchanges:
      - file: std_ciscat_etc_banner_net_setup

{% endif %}

std_etc_passwd_permissions:
  file.managed:
    - name: /etc/passwd
    - mode: 644
    - user: root
    - group: root

std_etc_passwd_permissions_log:
  logfile.write:
    - name: {{logfile}}
    - data: 'changing permissons on /etc/passwd 0600'
    - state_name: '{{sls}}'
    - onchanges:
      - file: std_etc_passwd_permissions

# 6.1.6 Ensure permissions on /etc/passwd- are configured
std_etc_passwd_dash_permissions:
  file.managed:
    - name: /etc/passwd-
    - mode: 600
    - user: root
    - group: root
    
std_etc_passwd_dash_permissions_log:
  logfile.write:
    - name: {{logfile}}
    - data: 'changing permissons on /etc/passwd- 0600'
    - state_name: '{{sls}}'
    - onchanges:
      - file: std_etc_passwd_dash_permissions

std_etc_group_permissions:
  file.managed:
    - name: /etc/group
    - mode: 644
    - user: root
    - group: root

std_etc_group_permissions_log:
  logfile.write:
    - name: {{logfile}}
    - data: 'changing permissons on /etc/group 0644'
    - state_name: '{{sls}}'
    - onchanges:
      - file: std_etc_group_permissions

# 6.1.8 Ensure permissions on /etc/group- are configured
std_etc_group_dash_permissions:
  file.managed:
    - name: /etc/group-
    - mode: 600
    - user: root
    - group: root
    
std_etc_group_dash_permissions_log:
  logfile.write:
    - name: {{logfile}}
    - data: 'changing permissons on /etc/group- 0600'
    - state_name: '{{sls}}'
    - onchanges:
      - file: std_etc_group_dash_permissions

std_root_bin_folder_create:
  file.directory:
    - name: /root/bin
    - dir_mode: 700
    - file_mode: 600
    - user: root
    - group: root

std_root_bin_folder_create_log:
  logfile.write:
    - name: {{logfile}}
    - data: 'changing permissons on /root/bin 0600'
    - state_name: '{{sls}}'
    - onchanges:
      - file: std_root_bin_folder_create

{% endif %}

#}