#!/bin/bash
{% from "java/map.jinja" import java_settings with context -%}
PATH=$PATH:/usr/java/jdk1.8/bin
JAVA_HOME=/usr/java/jdk1.8
export PATH
export JAVA_HOME
