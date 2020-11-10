#!/bin/bash
{% from "java/map.jinja" import java_settings with context -%}
{% set java_version = java_settings.common.version.split(':') -%}
export JAVA_HOME=/usr/java/latest
export JRE_HOME=/usr/java/latest/jre
