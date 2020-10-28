# Proxy setting to connect to public repositories
{% from "proxy/map.jinja" import proxy_settings with context -%}
{% set PROXY_HOST = proxy_settings.config.data.server -%}
{% set PROXY_USER = proxy_settings.config.data.username -%}
{% set PROXY_PASSWORD = proxy_settings.config.data.password -%}

export HTTP_PROXY={{PROXY_USER}}:{{ PROXY_PASSWORD }}@http://{{ PROXY_HOST }}/
export HTTPS_PROXY={{PROXY_USER}}:{{ PROXY_PASSWORD }}@https://{{ PROXY_HOST }}/
export NO_PROXY=localhost,::1,.example.com
