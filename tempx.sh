bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install

ufw allow 22
ufw allow 443
ufw enable

output=$(xray x25519 2>&1 | tr -d '/r')
private_key=$(echo "${output}" | grep -Ei '^private ?key:' | sed 's/^[^:]*: *//')
password=$(echo "${output}" | grep -E '^(Password|Public key)' | sed 's/^[^:]*: *//')

uuid=$(xray uuid 2>&1 | tr -d '/r' | grep -Eo '[0-9a-fA-F-]{36}' | head -n 1)

cat>/usr/local/etc/xray/config.json<<EOF
{
  "log": {
    "loglevel": "warning",
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log"
  },

  "inbounds": [
    {
      "port": 443,
      "protocol": "vless",
      "settings": {
        "users": [
          {
            "id": "$uuid",
            "flow": "xtls-rprx-vision"
          }
        ],
        "decryption": "none"
      },
      "sniffing": {
        "enabled": true,
        "destOverride": ["http", "tls", "quic"]
      },
      "streamSettings": {
        "method": "raw",
        "security": "reality",
        "realitySettings": {
          "target": "www.microsoft.com:443",
          "serverNames": ["www.microsoft.com"],
          "privateKey": "$private_key",
          "shortIds": ["156318"]
        }
      }
    }
  ],

  "outbounds": [
    {
      "tag": "direct",
      "protocol": "freedom",
      "settings": {}
    },
    {
      "tag": "block",
      "protocol": "blackhole",
      "settings": {}
    }
  ],

  "routing": {
    "domainStrategy": "AsIs",
    "rules": [
      {
        "ip": ["geoip:private"],
        "outboundTag": "block"
      },
      {
        "ip": ["geoip:cn"],
        "outboundTag": "block"
      },
      {
        "domain": ["geosite:cn"],
        "outboundTag": "block"
      }
    ]
  }
}
EOF
systemctl start xray

echo "password=${password}"
echo "uuid=${uuid}"

echo "OK"
