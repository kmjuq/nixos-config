# export https_proxy=http://192.168.31.172:7890 http_proxy=http://192.168.31.172:7890 all_proxy=socks5://192.168.31.172:7890
# export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7890
rm -rf /run/systemd/system/nix-daemon.service.d/
mkdir /run/systemd/system/nix-daemon.service.d/
cat <<EOF >/run/systemd/system/nix-daemon.service.d/override.conf
[Service]
Environment="http_proxy=http://192.168.31.172:7890"
Environment="https_proxy=http://192.168.31.172:7890"
Environment="all_proxy=socks5://192.168.31.172:7890"
EOF
systemctl daemon-reload
systemctl restart nix-daemon
