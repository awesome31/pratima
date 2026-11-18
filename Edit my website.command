#!/bin/bash
# Double-click this file to open the website editor in your browser.
cd "$(dirname "$0")" || exit 1
clear
echo ""
echo "  Starting the website editor..."
echo ""
if ! command -v ruby >/dev/null 2>&1; then
  echo "  This Mac does not have Ruby, which the editor needs."
  echo "  Open this folder in Claude and ask for help; HANDOVER.md explains the setup."
  echo ""
  read -r -p "  Press Return to close. " _
  exit 1
fi
if lsof -iTCP:4174 -sTCP:LISTEN -n -P >/dev/null 2>&1; then
  echo "  The editor is already running. Opening it in your browser."
  open "http://localhost:4174/"
  echo ""
  read -r -p "  Press Return to close this window. " _
  exit 0
fi
ruby editor/server.rb
echo ""
echo "  The editor has stopped. You can close this window."
