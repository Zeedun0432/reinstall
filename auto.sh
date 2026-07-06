#!/bin/bash

# Pastikan dua parameter diberikan
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <password> <img_version_or_custom_url>"
    echo "Available img_version: win_19, win_22, win_10, win_11"
    echo "Or provide a direct image URL (must end with .gz)"
    exit 1
fi

PASSWORD=$1
IMG_VERSION=$2
LOG_FILE="/root/reinstall.log"

# Cek apakah IMG_VERSION adalah URL langsung
if [[ "$IMG_VERSION" =~ ^https?://.*\.gz$ ]]; then
    IMG_URL="$IMG_VERSION"
else
    case $IMG_VERSION in
        win_19) IMG_URL="http://pterox.biz.id/windows2019.gz" ;;
        win_22) IMG_URL="http://pterox.biz.id/windows2022.gz" ;;
        win_10)  IMG_URL="http://pterox.biz.id/windows2022.gz" ;;
        win_11)  IMG_URL="http://pterox.biz.id/windows2022.gz" ;;
        *)
            echo "Invalid img_version or unsupported URL format."
            exit 1
            ;;
    esac
fi

echo "=== Reinstall started at $(date) ===" > "$LOG_FILE"
echo "Image URL: $IMG_URL" >> "$LOG_FILE"

# Download reinstall.sh, cek hasilnya benar-benar berhasil dan tidak kosong
rm -f reinstall.sh
curl -fsSL -o reinstall.sh https://raw.githubusercontent.com/Zeedun0432/reinstall/main/reinstall.sh
if [ $? -ne 0 ] || [ ! -s reinstall.sh ]; then
    echo "❌ Gagal download reinstall.sh (kosong atau curl error)" | tee -a "$LOG_FILE"
    exit 1
fi

chmod +x reinstall.sh

# Test dulu apakah IMG_URL bisa diakses sebelum lanjut dd (biar ga buang waktu kalau host lagi down)
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -I "$IMG_URL" --max-time 15)
if [ "$HTTP_CODE" != "200" ] && [ "$HTTP_CODE" != "302" ]; then
    echo "❌ Image URL tidak bisa diakses (HTTP $HTTP_CODE): $IMG_URL" | tee -a "$LOG_FILE"
    exit 1
fi

# Jalankan reinstall.sh, log semua output, dan CEK EXIT CODE-nya
bash reinstall.sh dd \
     --rdp-port 9999 \
     --password "$PASSWORD" \
     --img "$IMG_URL" 2>&1 | tee -a "$LOG_FILE"

REINSTALL_EXIT_CODE=${PIPESTATUS[0]}

if [ "$REINSTALL_EXIT_CODE" -ne 0 ]; then
    echo "❌ reinstall.sh gagal dengan exit code $REINSTALL_EXIT_CODE. TIDAK reboot." | tee -a "$LOG_FILE"
    exit 1
fi

echo "✅ Reinstall berhasil. Rebooting system in 5 seconds..." | tee -a "$LOG_FILE"
sleep 5
reboot
