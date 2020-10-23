# == State: firewalld._config
#
# This state configures firewalld.
#

{% from "firewalld/map.jinja" import firewalld with context %}

firewalld_config_directory:
  file.directory:            # make sure this is a directory
    - name: /etc/firewalld
    - user: root
    - group: root
    - mode: 750
    - require:
      - pkg: package_firewalld # make sure package is installed

configure_firewalld_service:
  file.managed:
    - name: /etc/firewalld/firewalld.conf
    - user: root
    - group: root
    - mode: 644
    - source: salt://firewalld/files/firewalld.conf
    - template: jinja
    - require:
      - pkg: install_firewalld_service 	# make sure package is installed
      - file: firewalld_config_directory
    - require_in:
      - service: start_firewalld_service
    - watch_in:
      - cmd: reload_firewalld_service # reload firewalld config
