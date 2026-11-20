#!/usr/bin/env bash
# Authenticode for RemoteAccess Windows files through Azure Artifact Signing
# with jsign: the same account and certificate profile as the Vigilance
# builds (vigi-seat scripts/sign-exe.sh). Each file costs one signature of
# the monthly allowance.
set -euo pipefail
: "${AZURE_SIGNING_TENANT_ID:?}" "${AZURE_SIGNING_CLIENT_ID:?}" "${AZURE_SIGNING_CLIENT_SECRET:?}"
JSIGN_VERSION=7.1
JAR="${RUNNER_TEMP:-/tmp}/jsign-${JSIGN_VERSION}.jar"
[ -f "$JAR" ] || curl -fsSL -o "$JAR" "https://github.com/ebourg/jsign/releases/download/${JSIGN_VERSION}/jsign-${JSIGN_VERSION}.jar"
# jsign's own token fetch answers 401 for this account; the login endpoint
# with the same three values works.
token=$(curl -fsS -X POST "https://login.microsoftonline.com/${AZURE_SIGNING_TENANT_ID}/oauth2/v2.0/token" \
  --data-urlencode "client_id=${AZURE_SIGNING_CLIENT_ID}" \
  --data-urlencode "client_secret=${AZURE_SIGNING_CLIENT_SECRET}" \
  -d grant_type=client_credentials \
  --data-urlencode "scope=https://codesigning.azure.net/.default" | jq -r .access_token)
[ -n "$token" ] && [ "$token" != null ] || { echo "Azure refused the signing credentials" >&2; exit 1; }
echo "::add-mask::$token"
for f in "$@"; do
  java -jar "$JAR" --storetype TRUSTEDSIGNING --keystore eus.codesigning.azure.net --storepass "$token" \
    --alias vigisigning/vigi-public --name RemoteAccess --url https://modul4r.com/remote "$f"
done
