net.ipv6.conf.all.forwarding:
  sysctl.present:
    - config: /etc/sysctl.d/ipv6_forwarding.conf
    - value: 0

net.ipv6.conf.default.forwarding:
  sysctl.present:
    - config: /etc/sysctl.d/ipv6_forwarding.conf
    - value: 0
