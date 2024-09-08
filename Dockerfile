FROM olbat/cupsd

COPY cndrvcups-capt_2.71-1_amd64.deb cndrvcups-common_3.21-1_amd64.deb /drivers/
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
        libatk-adaptor \
        libglade2-0 \
        gdb \
    && dpkg -i /drivers/*.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    chmod +x /scripts/start.sh

COPY start.sh /scripts/
RUN chmod +x /scripts/start.sh

CMD /scripts/start.sh
