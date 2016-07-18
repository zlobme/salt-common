#!pydsl
include("augeas.lenses")

tayga_conf = '''# Managed by Salt
tun-device nat64
data-dir /var/db/tayga'''

p_tayga = __salt__['pillar.get']('network:nat64:tayga', False)
if not p_tayga:
  raise ValueError('Isufficent pillar data')

def ca(*s):
  tayga_conf = ' '.join(s) + '\n'

ca('ipv4-addr', p_tayga['ipv4-addr'])
ca('ipv6-addr', p_tayga['ipv6-addr'])
ca('prefix', p_tayga['prefix'])
ca('dynamic-pool', p_tayga['dynamic-pool'])

if 'map' in p_tayga:
  for m in p_tayga['map']:
    ca('map', m['ipv4'], m['ipv6'])

state('/etc/tayga.conf').file.managed(
  mode=644, owner='root', group='root',
  contents=tayga_conf)

changes = [
  'set tayga_nat64 \'"true"\'',
]

def mlchap(key, values):
  changes.append('set ' + key + ' \'"' + '''\n\t'''.join(values) + '"\'')

mlchap('config_nat64', (p_tayga['ipv6-addr'], p_tayga['ipv4-addr']))
mlchap('routes_nat64', (p_tayga['prefix'], p_tayga['dynamic-pool']))
# mlchap('rc_net_nat64_provide', ('!net',))

state('append-nat64-config').augeas.change(
  context='/files/etc/conf.d/net',
  changes=changes).require(file='/usr/share/augeas/lenses/confd.aug')

state('/etc/init.d/net.nat64').file.symlink(target='net.lo').require(augeas='append-nat64-config')
