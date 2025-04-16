#!/bin/bash

# Değişkenleri başlat
max_device_num=0
max_bus=""
max_device=""


# "Raspberry Pi Pico" içeren lsusb çıktısını oku
while read -r line; do
    BUS=$(echo $line | awk '{print $2}')
    DEVICE=$(echo $line | awk '{print substr($4, 1, length($4)-1)}')
    # Device numarasını sayısal bir değere dönüştür (ön ek sıfırları kaldır)
    DEVICE_NUM=$((10#$DEVICE))
    # En büyük Device numarasını bul
    if [ $DEVICE_NUM -gt $max_device_num ]; then
        max_device_num=$DEVICE_NUM
        max_bus=$BUS
        max_device=$DEVICE
    fi
done < <(lsusb | grep "Raspberry Pi Pico")

# Sonucu kontrol et ve yazdır
if [ -n "$max_bus" ]; then
    echo "picotool load $1 -f --bus $max_bus --address $max_device"
else
    echo "Raspberry Pi Pico cihazı bulunamadı."
fi
