#!/bin/bash

kitana-webapp-install "HEY" https://app.hey.com https://www.hey.com/assets/images/general/hey.png
kitana-webapp-install "X" https://x.com/ https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/x-light.png
kitana-webapp-install "YouTube" https://youtube.com/ https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/youtube.png
kitana-webapp-install "GitHub" https://github.com/ https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/github-light.png
kitana-webapp-install "Grok" https://grok.com/ https://registry.npmmirror.com/@lobehub/icons-static-png/1.59.0/files/dark/grok.png
kitana-webapp-install "WhatsApp" https://web.whatsapp.com/ https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/whatsapp.png
kitana-webapp-install "Zoom" https://app.zoom.us/wc/home https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/zoom.png "${KITANA_DIR:-$HOME/.local/share/kitana}/bin/kitana-webapp-handler-zoom %u" "x-scheme-handler/zoommtg;x-scheme-handler/zoomus"
kitana-webapp-install "MarketMonkey" https://marketmonkeyterminal.com/app/terminal https://marketmonkeyterminal.com/images/mm-logo.png
