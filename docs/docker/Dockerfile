FROM debian:stable-slim

ARG GODOT_FLAVOR=stable
ARG GODOT_VERSION=4.7.2

RUN apt-get update && \
    apt-get install -y unzip wget && \
    rm -rf /var/lib/apt/lists/*

RUN wget -O "Godot_v${GODOT_VERSION}-${GODOT_FLAVOR}_linux.x86_64.zip" "https://downloads.godotengine.org/?version=${GODOT_VERSION}&flavor=${GODOT_FLAVOR}&slug=linux.x86_64.zip&platform=linux.64" && \
    unzip "Godot_v${GODOT_VERSION}-${GODOT_FLAVOR}_linux.x86_64.zip" -d /usr/bin && \
    rm "Godot_v${GODOT_VERSION}-${GODOT_FLAVOR}_linux.x86_64.zip" && \
    ln -s "/usr/bin/Godot_v${GODOT_VERSION}-${GODOT_FLAVOR}_linux.x86_64" /usr/bin/godot

RUN wget -O "Godot_v${GODOT_VERSION}-${GODOT_FLAVOR}_export_templates.tpz" "https://downloads.godotengine.org/?version=4.7.2&flavor=${GODOT_FLAVOR}&slug=export_templates.tpz&platform=templates" && \
    unzip "Godot_v${GODOT_VERSION}-${GODOT_FLAVOR}_export_templates.tpz" -d /tmp && \
    rm "Godot_v${GODOT_VERSION}-${GODOT_FLAVOR}_export_templates.tpz" && \
    mkdir -p /root/.local/share/godot/export_templates && \
    mv /tmp/templates "/root/.local/share/godot/export_templates/${GODOT_VERSION}.${GODOT_FLAVOR}"
