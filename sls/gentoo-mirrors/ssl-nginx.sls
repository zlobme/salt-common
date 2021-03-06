include:
  - nginx

/etc/ssl/nginx/gentoo-mirror/:
  file.directory:
    - create: True
    - mode: 750
    - user: root
    - group: nginx

/etc/ssl/nginx/gentoo-mirror/certificate.pem:
  file.managed:
    - source: salt://ssl/certificate-chain.tpl
    - template: jinja
    - defaults:
        cert_chain_key: 'gentoo-mirror'
    - mode: 644
    - user: root
    - group: nginx
    - watch_in:
      - service: nginx-reload

/etc/ssl/nginx/gentoo-mirror/privkey.pem:
  file.managed:
    - source: salt://ssl/privkey.tpl
    - template: jinja
    - defaults:
        privkey_key: 'gentoo-mirror'
    - mode: 600
    - user: root
    - group: root
    - watch_in:
      - service: nginx-reload
