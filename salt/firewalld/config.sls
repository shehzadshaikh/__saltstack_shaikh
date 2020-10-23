# == State: firewalld._config
#
# This state configures firewalld.
#

{% from "firewalld/map.jinja" import firewalld_settings with context %}

firewalld_config_directory:
  file.directory:            # make sure this is a directory
    - name: /etc/firewalld
    - user: root
    - group: root
    - mode: 750
    - require:
      - pkg: install_firewalld_service # make sure package is installed

configure_firewalld_service:
  file.managed:
    - name: {{ firewalld_settings.config.filename }}
    - user: root
    - group: root
    - mode: 644
    - source: {{ firewalld_settings.config.source }}
    - template: jinja
    - require:
      - pkg: install_firewalld_service 	# make sure package is installed
      - file: firewalld_config_directory
    - require_in:
      - service: start_firewalld_service
    - watch_in:
      - cmd: reload_firewalld_service # reload firewalld config
