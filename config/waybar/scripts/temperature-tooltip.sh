#!/usr/bin/env bash

# CPU (Zenpower)
CPU_TEMP=$(cat /sys/class/hwmon/hwmon1/temp1_input 2>/dev/null | awk '{printf "%.1f", $1/1000}')
CCD_TEMP=$(cat /sys/class/hwmon/hwmon1/temp3_input 2>/dev/null | awk '{printf "%.1f", $1/1000}')

# GPU (NVIDIA)
GPU_TEMP=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null)
GPU_MEM_TEMP=$(nvidia-smi --query-gpu=temperature.memory --format=csv,noheader,nounits 2>/dev/null || echo "N/A")

# NVMe
NVME_TEMP=$(cat /sys/class/hwmon/hwmon0/temp1_input 2>/dev/null | awk '{printf "%.1f", $1/1000}')
NVME_S1=$(cat /sys/class/hwmon/hwmon0/temp2_input 2>/dev/null | awk '{printf "%.1f", $1/1000}')

# Motherboard / VRM (NCT6795)
SYSTIN=$(cat /sys/class/hwmon/hwmon3/temp1_input 2>/dev/null | awk '{printf "%.1f", $1/1000}')
VRM_TEMP=$(cat /sys/class/hwmon/hwmon3/temp5_input 2>/dev/null | awk '{printf "%.1f", $1/1000}')
PCH_TEMP=$(cat /sys/class/hwmon/hwmon3/temp7_input 2>/dev/null | awk '{printf "%.1f", $1/1000}')

# Prepare tooltip text with escaped newlines for JSON
TOOLTIP="󰻠 CPU Tdie:  ${CPU_TEMP}°C\\n󰻠 CPU CCD1:  ${CCD_TEMP}°C\\n󰢮 GPU Core:  ${GPU_TEMP}°C\\n󰢮 GPU Mem:   ${GPU_MEM_TEMP}°C\\n󰋊 NVMe:      ${NVME_TEMP}°C\\n󰋊 NVMe S1:   ${NVME_S1}°C\\n󰘚 System:    ${SYSTIN}°C\\n󰘚 VRM:       ${VRM_TEMP}°C\\n󰘚 PCH:       ${PCH_TEMP}°C"

# Output JSON
printf '{"text": "%02.0f°C", "tooltip": "%s"}\n' "$CPU_TEMP" "$TOOLTIP"
