#!/usr/bin/env bash
# 12-service-check.sh — check that services are running and websites respond.
#
# Run: ./12-service-check.sh
#      ./12-service-check.sh ssh nginx docker
#
# Edit the URLS list below for your own sites.

# Use the service names given as arguments, or check ssh and cron by default
if [[ $# -gt 0 ]]; then
    SERVICES=("$@")
else
    SERVICES=(ssh cron)
fi

URLS=(
    "https://example.com"
)

green() { printf '\e[32m%s\e[0m\n' "$*"; }
red()   { printf '\e[31m%s\e[0m\n' "$*"; }

failures=0

echo "== Services"
for svc in "${SERVICES[@]}"; do
    if systemctl is-active --quiet "$svc"; then
        green "  [ OK ]  $svc is running"
    else
        red   "  [FAIL]  $svc is not running ($(systemctl is-active "$svc" 2>/dev/null))"
        (( failures++ ))
    fi
done

echo "== Websites"
for url in "${URLS[@]}"; do
    code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 "$url" || true)
    if [[ "$code" =~ ^(2|3) ]]; then
        green "  [ OK ]  $url ($code)"
    else
        red   "  [FAIL]  $url (${code:-no response})"
        (( failures++ ))
    fi
done

echo
if (( failures == 0 )); then
    green "All checks passed."
else
    red "$failures check(s) failed."
    exit 1
fi
