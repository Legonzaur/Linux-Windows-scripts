echo $((100*$(cat /sys/class/power_supply/battery/charge_now)/$(cat /sys/class/power_supply/battery/charge_full)))
