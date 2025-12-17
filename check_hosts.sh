#!/bin/bash

# Script pentru verificarea intrărilor din /etc/hosts
# Versiunea 2 - cu funcție
# Modificat de: Studentul A

echo "=== Script verificare /etc/hosts ==="
echo "Modificat de: Studentul A"
echo "======================================"
echo "modificat modificare modifica etctectetcetcte"

# Funcție pentru verificarea validității unei adrese IP
# Parametri:
#   $1 - hostname
#   $2 - IP din /etc/hosts
#   $3 - server DNS (opțional, implicit se folosește cel din sistem)
verify_ip() {
    local hostname="$1"
    local expected_ip="$2"
    local dns_server="$3"
    
    # Verificăm dacă avem parametrii necesari
    if [[ -z "$hostname" || -z "$expected_ip" ]]; then
        return 1
    fi
    
    # Construim comanda nslookup
    local nslookup_cmd="nslookup $hostname"
    if [[ -n "$dns_server" ]]; then
        nslookup_cmd="nslookup $hostname $dns_server"
    fi
    
    # Obținem IP-ul real de la DNS
    local real_ip=$($nslookup_cmd 2>/dev/null | grep -A1 "Name:" | grep "Address:" | awk '{print $2}' | head -n1)
    
    # Comparăm IP-urile
    if [[ -n "$real_ip" && "$real_ip" != "$expected_ip" ]]; then
        echo "Bogus IP for $hostname in /etc/hosts !"
        echo "  /etc/hosts: $expected_ip"
        echo "  DNS server: $real_ip"
        if [[ -n "$dns_server" ]]; then
            echo "  (folosind DNS: $dns_server)"
        fi
        return 1
    fi
    
    return 0
}

# Server DNS implicit (poate fi schimbat)
DNS_SERVER="${1:-}"

# Citim și verificăm fișierul /etc/hosts
cat /etc/hosts | while read -r line; do
    # Ignorăm liniile goale și comentariile
    if [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]]; then
        continue
    fi
    
    # Extragem IP-ul și numele
    ip=$(echo "$line" | awk '{print $1}')
    hostname=$(echo "$line" | awk '{print $2}')
    
    # Verificăm dacă avem ambele câmpuri
    if [[ -z "$ip" || -z "$hostname" ]]; then
        continue
    fi
    
    # Apelăm funcția de verificare
    verify_ip "$hostname" "$ip" "$DNS_SERVER"
done