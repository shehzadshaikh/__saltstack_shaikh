# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "cis-benchmark/map.jinja" import cis_benchmark with context %}

{% if grains['os'] == 'CentOS' or grains['os'] == 'CentOS' -%}
  {% if grains['osmajorrelease']|int == 7 -%}
include:
  - {{ slspath }}.rhel7.enforce
  {% endif -%}
{% endif -%}
