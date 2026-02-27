
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

# Cek apakah IMG_VERSION adalah URL langsung
if [[ "$IMG_VERSION" =~ ^https?://.*\.gz$ ]]; then
    IMG_URL="$IMG_VERSION"
else
    # Mapping img_version ke URL
    case $IMG_VERSION in
        win_19)
            IMG_URL="http://pterox.biz.id/windows2019.gz"
            ;;
        win_22)
            IMG_URL="http://pterox.biz.id/windows2022.gz"
            ;;
        win_10)
            IMG_URL="http://pterox.biz.id/windows2022.gz"
            ;;
        win_11)
            IMG_URL="http://pterox.biz.id/windows2022.gz"
            ;;
        *)
            echo "Invalid img_version or unsupported URL format."
            echo "Use one of: win_19, win_22, win_10, win_11"
            echo "Or provide a direct .gz URL"
            exit 1
            ;;
    esac
fi

# Download reinstall.sh menggunakan curl atau wget
curl -O https://raw.githubusercontent.com/Zeedun0432/reinstall/main/reinstall.sh || \
wget -O reinstall.sh https://raw.githubusercontent.com/Zeedun0432/reinstall/main/reinstall.sh

# Berikan izin eksekusi pada reinstall.sh
chmod +x reinstall.sh

# Jalankan reinstall.sh dengan parameter yang diberikan
bash reinstall.sh dd \
     --rdp-port 9999 \
     --password "$PASSWORD" \
     --img "$IMG_URL"

# Reboot sistem setelah instalasi selesai
echo "Rebooting system in 5 seconds..."
sleep 5
reboot
