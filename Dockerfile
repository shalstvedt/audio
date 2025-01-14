# --- Note on PulseAudio version ---
# Alpine 3.15 pins PulseAudio version to 15.x.x
# See https://pkgs.alpinelinux.org/packages?name=pulseaudio&branch=v3.15

ARG BALENA_ARCH=amd64

FROM balenalib/$BALENA_ARCH-alpine:3.15-run
WORKDIR /usr/src

# UDev is required to autodetect ALSA devices
# DBus is required for module-bluetooth-discover
ENV UDEV=on
ENV DBUS_SYSTEM_BUS_ADDRESS=unix:path=/host/run/dbus/system_bus_socket

# Install PulseAudio and dependencies
RUN install_packages \
  alsa-utils \
  mawk \
  pulseaudio~=15 \
  pulseaudio-alsa \
  pulseaudio-bluez \
  pulseaudio-utils \
  xxd
  
RUN usermod -a -G 29 root

# For local development
#dev-cmd-live=pulseaudio || balena-idle

# PulseAudio configuration
COPY pulseaudio/block.pa /etc/pulse/default.pa.d/00-audioblock.pa
COPY pulseaudio/client.conf /etc/pulse/client.conf
COPY pulseaudio/daemon.conf /etc/pulse/daemon.conf

# UDev configuration
COPY udev/95-balena-audio.rules /etc/udev/rules.d/95-balena-audio.rules

# Entrypoint
COPY entry.sh .
ENTRYPOINT [ "/bin/bash", "/usr/src/entry.sh" ]

CMD [ "pulseaudio" ]
