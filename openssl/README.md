### Cert for NGINX
Setup openssl using gnuopenssl.

Verify if OpenSSL is installed or not.
```
openssl version
```

#### crt/key
Make sure configuration file in folder present.

```
openssl req -config openssl.cnf -x509 -nodes -days 365 -newkey rsa:2048 -keyout core2io.key -out core2io.crt -subj "/C=IN/ST=Maharashtra/L=Pune/O=k8cluster core2io/CN=core2io.k8cluster.io"
```

#### pfx
Create pfx file from crt and key file.

```
// Password needed to crypt 'crypticpassword'
openssl pkcs12 -export -out core2io.pfx -inkey core2io.key -in core2io.crt
```