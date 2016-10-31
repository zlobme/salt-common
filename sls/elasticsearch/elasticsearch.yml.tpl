# Generated by salt
{% set config = salt['pillar.get']('elastic:config') %}
{% set cluster = config['cluster'] %}
{% set node = config['node'] %}
{% set zen = config['discovery']['zen'] %}
{% set hosts = salt['pillar.get']('elastic:config:discovery:hosts', []) %}
cluster:
  name: {{ cluster['name']}}
{{ cluster.get('extra', {}) | yaml() | indent(2) }}

node:
  name: {{ node.get('name', '${HOSTNAME}') }}
  master: {{ node.get('master', False) }}
  data: {{ node.get('data', False) }}  
  location: {{ node.get('location', '') }}
  max_local_storage_nodes: {{ node.get('max_local_storage_nodes', 1) }}
{{ node.get('extra', {}) | yaml() | indent(2) }}

path:
  data: /var/lib/elasticsearch
  logs: /var/log/elasticsearch

bootstrap.mlockall: true

network.host: {{ salt['pillar.get']('elastic:config:network:host', '${HOSTNAME}') }}

http.port: {{ salt['pillar.get']('elastic:config:http:port', 9200) }}

gateway.recover_after_nodes: {{ salt['pillar.get'](
    'elastic:config:gateway:recover_after_nodes', hosts|length/2) }}

discovery:
  zen:
    {% if hosts %}
    ping.unicast.hosts:
      {% for host in hosts %}
      {% if (host != salt['grains.get']('fqdn', 'localhost')) %}
      - {{ host }}
      {% endif %}
      {% endfor %}
    {% endif %}
    minimum_master_nodes: {{ salt['pillar.get']('elastic:config:discovery:zen:minimum_master_nodes', 1) }}
{{ zen.get('extra', {}) | yaml() | indent(4) }}

{{ config.get('extra', {}) | yaml() | indent(0) }}
