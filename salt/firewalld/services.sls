# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "firewalld/map.jinja" import firewalld_settings with context %}

enable_std_firewall:
  firewalld.present:
    - name: {{ firewalld_settings.default_zone }}
    - default: True
    - services:
    {% for service in firewalld_settings.predefined_services %}
      - {{ service }}
    {% endfor %}
    - ports:
    {% for port in firewalld_settings.custom_services.ports %}
      - {{ port }}
    {% endfor %}
