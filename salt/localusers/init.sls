# -*- username: coding utf-8 -*-
# vim: ft=sls

{% from "users/map.jinja" import users_settings with context %}

include:
  - {{ slspath }}/sudoers
  - {{ slspath }}/users
  - {{ slspath }}/permissions
