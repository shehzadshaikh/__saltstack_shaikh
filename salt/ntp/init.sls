{% from "ntp/files/map.jinja" import ntp_settings with context %}

install_ntp_service:
  pkg.installed:
    - name: {{ ntp_settings.package.name }}

{#
configure_ntp_service:
  file.managed:
    - template: jinja
    - name: {{ ntp_settings.config.filename }}
    - source: {{ ntp_settings.config.source }}
#}

start_ntp_service:
  service.running:
    - name: {{ ntp_settings.service.name }}
    - enable: {{ ntp_settings.service.enable }}
    - watch:
      - pkg: install_ntp_service
{#
      - file: configure_ntp_service
#}

disable_chrony_service:
  service.dead:
    - name: chronyd
    - enable: false
    - onlyif:
      - rpm -q chrony

