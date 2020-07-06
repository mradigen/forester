#!/bin/sh

bluetooth_print() {
    bluetoothctl | while read REPLY; do
        if [ "$(systemctl is-active "bluetooth.service")" = "active" ]; then
            echo '%{B#7c746a}%{F#000000}  B  %{B- F-}'
			
            devices_paired=$(bluetoothctl paired-devices | grep Device | cut -d ' ' -f 2)
            counter=0

            echo "$devices_paired" | while read -r line; do
                device_info=$(bluetoothctl info "$line")

                if echo "$device_info" | grep -q "Connected: yes"; then
                    device_alias=$(echo "$device_info" | grep "Alias" | cut -d ' ' -f 2-)

                    if [ $counter -gt 0 ]; then
                        echo ", %s" "$device_alias"
                    else
                        echo "%{B#9cbdd8}%{F#000000} $device_alias %{B- F-}"
                    fi

                    counter=$((counter + 1))
                fi
            done

            # printf '\n'
        else
            echo "%{B#1c3c51}%{F#edf2fb} Off %{B- F-}"
        fi
    done
}

bluetooth_toggle() {
    if bluetoothctl show | grep -q "Powered: no"; then
        bluetoothctl power on >> /dev/null
        sleep 1

        devices_paired=$(bluetoothctl paired-devices | grep Device | cut -d ' ' -f 2)
        echo "$devices_paired" | while read -r line; do
            bluetoothctl connect "$line" >> /dev/null
        done
    else
        devices_paired=$(bluetoothctl paired-devices | grep Device | cut -d ' ' -f 2)
        echo "$devices_paired" | while read -r line; do
            bluetoothctl disconnect "$line" >> /dev/null
        done

        bluetoothctl power off >> /dev/null
    fi
}

case "$1" in
    --toggle)
        bluetooth_toggle
        ;;
    *)
        bluetooth_print
        ;;
esac
