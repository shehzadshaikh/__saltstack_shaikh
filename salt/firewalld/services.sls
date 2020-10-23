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


{#
    - service: 
    - prune_block_icmp: {{ firewalld_settings.prune_block_icmp }}
    - prune_interfaces: {{ firewalld_settings.prune_interfaces }}
    - prune_services: {{ firewalld_settings.prune_services }}
    - prune_port_fwd: {{ firewalld_settings.prune_port_fwd }}
    - prune_ports: {{ firewalld_settings.prune_ports }}
    - prune_sources: {{ firewalld_settings.prune_sources }}
    - prune_rich_rules: {{ firewalld_settings.prune_rich_rules }}
    - services: 
#}
