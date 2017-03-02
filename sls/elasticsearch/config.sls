#!pydsl
# -*- mode: python -*-
from salt.utils import dictupdate
import yaml

state('/etc/elasticsearch/').file.directory(
  create=True, mode=755, user='root', group='root')

fqdn = __salt__['grains.get']('fqdn')
fqdn_ipv6 = __salt__['grains.get']('fqdn_ipv6')
hosts = __salt__['pillar.get']('elastic:hosts', [])

l_nofile = __salt__['pillar.get']('elastic:limits:nofile', 1048576)
l_memlock = __salt__['pillar.get']('elastic:limits:memlock', 'unlimited')
max_map_count = __salt__['pillar.get']('elastic:limits:max_map_count', 262144)

# defaults
config = {
  'node': {
    'name': '${HOSTNAME}',
    'master': False, 'data': False,
    'max_local_storage_nodes': 1,
  },
  'path': {
    'data': '/var/lib/elasticsearch',
    'logs': '/var/log/elasticsearch',
  },
  'bootstrap': {'memory_lock': True},
  'network': { 'host': '${HOSTNAME}' },
  'http': { 'port': 9200 },
  'gateway': { 'recover_after_nodes': len(hosts)/2 },
  'discovery': { 'zen': {
    'minimum_master_nodes': 1,
    'ping': { 'unicast': {}},
  }},
}

config['discovery']['zen']['ping']['unicast']['hosts'] = filter(
  lambda x: x != fqdn and x not in fqdn_ipv6,
  hosts)
dictupdate.update(config, __pillar__['elastic']['config'])

state('/etc/elasticsearch/elasticsearch.yml').file.managed(
  mode=644, user='root', group='root',
  contents="# This file is generated by Salt\n" + yaml.dump(config))

state('/etc/conf.d/elasticsearch').file.managed(
  mode=644, user='root', group='root',
  template='jinja', source="salt://elasticsearch/files/elasticsearch.confd.tpl",
  default={'l_nofile': l_nofile, 'l_memlock': l_memlock,
           'max_map_count': max_map_count, 'es_startup_sleep_time': 10})

state('/etc/security/limits.d/elasticsearch.conf').file.managed(
  mode=644, user='root', group='root',
  contents='\n'.join([
    "elasticsearch soft nofile {0}".format(l_nofile),
    "elasticsearch hard nofile {0}".format(l_nofile),
    "memlock {0}".format(l_memlock)]))
