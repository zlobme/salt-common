-----BEGIN OPENSSH PRIVATE KEY-----
{{ salt['pillar.get']('pki:openssh:'+privkey_key+':privkey').rstrip('\n') }}
-----END OPENSSH PRIVATE KEY-----