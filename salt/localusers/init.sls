# -*- username: coding utf-8 -*-
# vim: ft=sls

{% from "localusers/map.jinja" import localusers_settings with context %}

include:
  - {{ slspath }}/sudoers

{# TODO: loop through users list/map #}
create_user_{{ localusers_settings.userlist.username }}:
  user.present:
    - name: {{ localusers_settings.userlist.username }}
    - groups:
      - {{ localusers_settings.userlist.groups.name }}

ssh_key_{{ localusers_settings.userlist.username }}:
  ssh_auth.present:
    - user: {{ localusers_settings.userlist.username }}
    - enc: ssh-rsa
    - source: {{ localusers_settings.userlist.ssh_auth_source }}
    - config: '%h/.ssh/authorized_keys'
