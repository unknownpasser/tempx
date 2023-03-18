curl -O https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh
bash install-release.sh
ufw allow 28080
cat>/usr/local/etc/v2ray/config.json<<EOF
{
    "log":
    {
        "loglevel": "warning"
    },
    "routing":
    {
        "domainStrategy": "AsIs",
        "rules":
        [
            {
                "ip":
                [
                    "geoip:private"
                ],
                "outboundTag": "blocked",
                "type": "field"
            }
        ]
    },
    "inbounds":
    [
        {
            "port": 28080,
            "protocol": "vmess",
            "settings":
            {
                "clients":
                [
                    {
                        "id": "ad6d712f-770b-4f97-af7c-8b2cfd207b0a",
                        "alterId": 0
                    }
                ]
            }
        }
    ],
    "outbounds":
    [
        {
            "protocol": "freedom"
        },
        {
            "protocol": "blackhole",
            "tag": "blocked"
        }
    ]
}
EOF
systemctl start v2ray

echo 'Ok'
