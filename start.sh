#! /usr/bin/env bash

# Start cupsd in background to use lpadmin
/usr/sbin/cupsd

PRINTER_NAME='CannonLBP-1120'

if [ `lpstat -p 2>&1 | grep -E "${PRINTER_NAME}" -c || true` = "0" ]; then
  echo "..installing printer driver ${PRINTER_NAME}.."
  lpadmin \
      -v 'socket://0.0.0.0' \
      -p  "${PRINTER_NAME}"\
      -P /usr/share/ppd/CNCUPSLBP1120CAPTJ.ppd \
      -m 'Canon LBP1120 CAPT ver.1.5' \
      -L 'Kitchen' \
      -o 'Color=Mono' \
      -o 'Enhance Black Printing=ON' \
      -o 'Skip Blank Page=ON' \
      -E

  lpadmin -d 'Cannon LBP-1120'

#  sudo sed -ir 's/DefaultBRMonoColor.*/DefaultBRMonoColor: mono/g;
#              s/DefaultBREnhanceBlkPrt.*/DefaultBREnhanceBlkPrt: ON/g;
#              s/DefaultBRSkipBlank.*/DefaultBRSkipBlank: ON/g;' \
#              "/etc/cups/ppd/${PRINTER_NAME}.ppd"
fi

sed -ir -e "s/#enable-dbus=yes/enable-dbus=no/" /etc/avahi/avahi-daemon.conf
/usr/sbin/avahi-daemon -D

# Hack to keep container running with only background process
tail -f /var/log/cups/access_log
