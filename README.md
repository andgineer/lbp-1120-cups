# lbp-1120-cups

docker run \
    -d \
    -p 631:631 \
    -p 5353:5353 \
    -v /var/run/dbus:/var/run/dbus \
    --name lbp-1120 \
    lbp-1120-cups
