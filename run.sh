#!/bin/bash

apt update && apt upgrade -y
apt install neofetch -y

# Fungsi untuk menggambar grafik bar
draw_bar() {
  local value=$1
  local max=20  # Panjang grafik
  local filled=$((value * max / 100))
  local empty=$((max - filled))
  
  printf "["
  for ((i = 1; i <= filled; i++)); do
    printf "#"
  done
  for ((i = 1; i <= empty; i++)); do
    printf "-"
  done
  printf "]"
}

# Informasi ISP
isp=$(curl -s https://ipinfo.io/org | sed 's/^AS[0-9]* //;s/^ //g')
isp=${isp:-"Unknown ISP"}

# Informasi Virtualisasi
virtualization=$(hostnamectl | grep "Virtualization" | awk -F': ' '{print $2}')
virtualization=${virtualization:-"Unknown"}

# Informasi CPU
cpu_cores=$(grep -c ^processor /proc/cpuinfo)
cpu_usage=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage}')
cpu_usage_int=${cpu_usage%.*}

# Informasi RAM
ram_info=$(free -m | awk '/^Mem:/ {print $3, $2}')
ram_used=$(echo $ram_info | awk '{print $1}')
ram_total=$(echo $ram_info | awk '{print $2}')
ram_percentage=$((ram_used * 100 / ram_total))

# Informasi Disk
disk_info=$(df -h / | awk '/\// {print $3, $2, $5}')
disk_used=$(echo $disk_info | awk '{print $1}')
disk_total=$(echo $disk_info | awk '{print $2}')
disk_percentage=$(echo $disk_info | awk '{print $3}' | sed 's/%//')

clear
# Header
neofetch
echo "====================================="
echo "           System Information        "
echo "====================================="

# Output ISP
echo " "
printf "ISP         : %s\n" "$isp"
printf "Virtualisasi: %s\n" "$virtualization"

# Output CPU Information
echo " "
printf "CPU Cores   : %d\n" "$cpu_cores"
printf "CPU Usage   : %d%%\n" "$cpu_usage_int"
printf "Grafik Usage: "
draw_bar $cpu_usage_int
printf "\n"

# Output RAM Information
echo " "
printf "RAM Total   : %d MB\n" "$ram_total"
printf "RAM Usage   : %d MB / %d MB\n" "$ram_used" "$ram_total"
printf "Grafik Usage: "
draw_bar $ram_percentage
printf " (%d%%)\n" "$ram_percentage"

# Output Disk Information
echo " "
printf "Disk Total  : %s\n" "$disk_total"
printf "Disk Usage  : %s / %s (%d%%)\n" "$disk_used" "$disk_total" "$disk_percentage"
printf "Grafik Usage: "
draw_bar $disk_percentage
printf "\n"

# Footer
echo "====================================="
echo " "