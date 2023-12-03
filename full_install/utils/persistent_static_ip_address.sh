#!/bin/bash

# Replace this with the path to your utility
IP_MAC_EXPORT_UTILITY="/tmp/ip_mac_export"
#TESTING: IP_MAC_EXPORT_UTILITY="./ip_mac_export"

# Check if the utility is available
if [ ! -f "$IP_MAC_EXPORT_UTILITY" ]; then
    echo "IP/MAC export utility not found at $IP_MAC_EXPORT_UTILITY."
    exit 1
fi

# Execute the utility and capture its output
UTILITY_OUTPUT=$("$IP_MAC_EXPORT_UTILITY")

# Parse the interface with a non-local IP address (not 127.0.0.1)
readarray -t lines <<< "$UTILITY_OUTPUT"
for ((i=0; i<${#lines[@]}; i++)); do
    if [[ ${lines[i]} =~ "Interface :" ]]; then
        current_interface=$(echo "${lines[i]}" | awk '{print $3}')
    fi
    if [[ ${lines[i]} =~ "IP Address :" ]] && ! [[ ${lines[i]} =~ "127.0.0.1" ]]; then
        CURRENT_IP=$(echo "${lines[i]}" | awk '{print $4}')
        INTERFACE="$current_interface"
        break
    fi
done
# 
STATIC_IP="$CURRENT_IP"
GATEWAY=$(ip route | grep default | awk '{print $3}')
CONNECTION_NAME="static-${INTERFACE}" # Connection name for NetworkManager
# Get the type of the network interface
INTERFACE_TYPE=$(nmcli -t -f GENERAL.TYPE device show "$INTERFACE" | cut -d':' -f2)
if [[ $INTERFACE_TYPE == "wifi" ]]; then
    NM_TYPE="wifi"
else
    NM_TYPE="ethernet"
fi

# Generate the NetworkManager connection profile configuration
#STATIC_NETWORK_PROFILE_LOCATION="/etc/NetworkManager/system-connections/$CONNECTION_NAME.nmconnection"
STATIC_NETWORK_PROFILE_LOCATION="../../scratch_utils/TEST-$CONNECTION_NAME.nmconnection"

echo "Generating NetworkManager Static IP Address Profile configuration for $INTERFACE..."
cat <<EOF > "$STATIC_NETWORK_PROFILE_LOCATION"
[connection]
id=$CONNECTION_NAME
type=$NM_TYPE
interface-name=$INTERFACE

[ipv4]
method=manual
address1=$STATIC_IP,$GATEWAY
dns=$GATEWAY
EOF

echo "NetworkManager profile configuration generated at $STATIC_NETWORK_PROFILE_LOCATION"
echo "The static IP configuration will be applied on the next boot."

# End of the configuration
echo "Network setup configuration completed."
