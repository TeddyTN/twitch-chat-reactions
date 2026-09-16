FROM debian:stable-slim

ARG GODOT_VERSION=4.7.2

RUN apt-get update && \
    apt-get install -y unzip wget && \
    rm -rf /var/lib/apt/lists/*

RUN wget -O "Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip" "https://downloads.godotengine.org/?version=${GODOT_VERSION}&flavor=stable&slug=linux.x86_64.zip&platform=linux.64" && \
    unzip "Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip" -d /usr/bin && \
    rm "Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip" && \
    ln -s "/usr/bin/Godot_v${GODOT_VERSION}-stable_linux.x86_64" /usr/bin/godot

RUN wget -O "Godot_v${GODOT_VERSION}-stable_export_templates.tpz" "https://downloads.godotengine.org/?version=4.7.2&flavor=stable&slug=export_templates.tpz&platform=templates" && \
    unzip "Godot_v${GODOT_VERSION}-stable_export_templates.tpz" -d /tmp && \
    rm "Godot_v${GODOT_VERSION}-stable_export_templates.tpz" && \
    mkdir -p /.local/share/godot/export_templates && \
    mv /tmp/templates "/.local/share/godot/export_templates/${GODOT_VERSION}.stable"
