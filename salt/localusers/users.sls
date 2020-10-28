# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "localusers/map.jinja" import localusers_settings with context %}

users_group_{{ localusers_settings.username }}_{{ group }}:
  group.present:
    - name: {{ group }}
    {% if (user.gid is defined) and (group == user.username) %}
    - gid: {{ user.gid }}
    {% endif %}
{% endif %}
{% endfor %}