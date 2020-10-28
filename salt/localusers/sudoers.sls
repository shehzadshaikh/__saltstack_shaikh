# -*- username: coding utf-8 -*-
# vim: ft=sls

{% from "localusers/map.jinja" import localusers_settings with context %}

create_sudoers:
  file.managed:
    - name: {{ localusers_settings.userlist.sudoers_file }}
    - user: root
    - group: root
    - mode: 440

{# TODO: loop through users list/map #}
create_group_{{ localusers_settings.userlist.groups.name }}:
  group.present:
    - name: {{ localusers_settings.userlist.groups.name }}
    - gid: {{ localusers_settings.userlist.groups.id }}

sudoers_group_{{ localusers_settings.userlist.groups.name }}:
  file.append:
    - name: {{ localusers_settings.userlist.sudoers_file }}
    - makedirs: True
    - text: |
        %{{ localusers_settings.userlist.groups.name }} ALL=(ALL:ALL) NOPASSWD:ALL
