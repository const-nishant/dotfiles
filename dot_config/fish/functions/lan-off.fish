function lan-off --description 'Remove every ufw rule added by lan-on and stop sshd'
    # Delete by rule number, highest first, so remaining numbers stay valid.
    # Matching on the "lan-mode" comment works even if the subnet changed since lan-on.
    set -l nums (sudo ufw status numbered | string match -r '^\[\s*(\d+)\].*lan-mode' --groups-only | sort -rn)
    for n in $nums
        sudo ufw --force delete $n
    end
    sudo systemctl stop sshd
    echo "LAN mode OFF. Removed "(count $nums)" rule(s); sshd stopped."
end
