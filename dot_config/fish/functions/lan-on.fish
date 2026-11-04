function lan-on --description 'Open Node dev ports + SSH to the current LAN subnet only (undo with lan-off)'
    set -l iface (ip -4 route show default | string match -r 'dev (\S+)' --groups-only | head -n1)
    set -l subnet (ip -4 route show dev $iface scope link | string match -r '^\d+\.\d+\.\d+\.\d+/\d+' | head -n1)
    set -l ssid (nmcli -t -f ACTIVE,SSID dev wifi 2>/dev/null | string match -r '^yes:(.*)' --groups-only)

    if test -z "$subnet"
        echo "lan-on: could not detect the LAN subnet (are you connected?)"
        return 1
    end

    echo "Network: "(test -n "$ssid"; and echo $ssid; or echo $iface)"  subnet: $subnet"
    read -l -P "Open dev ports + SSH to everyone on this network? [y/N] " ans
    if not string match -qi y $ans
        echo "Cancelled."
        return 1
    end

    # Node/web dev ports: Express/Next/CRA, alt, Vite, alt HTTP, Metro/Expo
    for p in 3000 3001 4000 5000 5173 8080 8081
        sudo ufw allow from $subnet to any port $p proto tcp comment lan-mode
    end

    # SSH, rate-limited (blocks IPs that open too many connections)
    sudo ufw limit from $subnet to any port 22 proto tcp comment lan-mode
    sudo systemctl start sshd

    echo "LAN mode ON for $subnet. Run lan-off when done."
end
