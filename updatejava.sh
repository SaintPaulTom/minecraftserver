#!/bin/sh

NORMAL_OUT=/dev/stdout
ERROR_OUT=/dev/stderr
VERSION_MANIFEST='https://piston-meta.mojang.com/mc/game/version_manifest.json'
JAR_PATH=/opt/minecraft/java/jars
NORMAL_OUT=/dev/stdout
ERROR_OUT=/dev/stderr

echo "Downloading Version Manifest from: $VERSION_MANIFEST" > $NORMAL_OUT
VERSION_MANIFEST_DATA=$(curl -s "$VERSION_MANIFEST")
VERSION_RELEASE=$(echo "$VERSION_MANIFEST_DATA" | jq -r '.latest.release' )
VERSION_SNAPSHOT=$(echo "$VERSION_MANIFEST_DATA" | jq -r '.latest.snapshot' )
RELEASE_JAR=$JAR_PATH/minecraft_server.$VERSION_RELEASE.jar
SNAPSHOT_JAR=$JAR_PATH/minecraft_server.$VERSION_SNAPSHOT.jar
echo "Done" > $NORMAL_OUT

echo "Latest release version: $VERSION_RELEASE" > $NORMAL_OUT
if [ -e $RELEASE_JAR ]
then
  echo "Latest release already downloaded" > $NORMAL_OUT
else
  RELEASE_MANIFEST=$(echo $VERSION_MANIFEST_DATA | jq -r --arg VERSION_TARGET $VERSION_RELEASE '.versions | .[] | select(.id==$VERSION_TARGET) | .url')
  echo "Downloading Package Manifest from: $RELEASE_MANIFEST" > $NORMAL_OUT
  RELEASE_MANIFEST_DATA=$(curl -s "$RELEASE_MANIFEST")
  echo "Done" > $NORMAL_OUT
  echo "Parsing Package Manifest" > $NORMAL_OUT
  RELEASE_NEWJAR_URL=$(jq -rn --argjson url "$RELEASE_MANIFEST_DATA" '$url.downloads.server.url')
  RELEASE_NEWJAR_SHA1=$(jq -rn --argjson sha1 "$RELEASE_MANIFEST_DATA" '$sha1.downloads.server.sha1')
  echo "Done" > $NORMAL_OUT
  echo "Downloading release jar" > $NORMAL_OUT
  curl -s -L -f -o $RELEASE_JAR $RELEASE_NEWJAR_URL
  echo "Done" > $NORMAL_OUT
  echo "Calculating SHA1 sum" > $NORMAL_OUT
  RELEASE_SHA1=$(sha1sum $RELEASE_JAR | cut -d " " -f 1 )
  if [ $RELEASE_NEWJAR_SHA1 = $RELEASE_SHA1 ]
  then
    echo "Hashes match" > $NORMAL_OUT
  else
    echo "Hashes mismatch - check jar file" > $ERROR_OUT
  fi
fi

echo "Latest snapshot version: $VERSION_SNAPSHOT" > $NORMAL_OUT
if [ -e $SNAPSHOT_JAR ]
then
  echo "Latest snapshot already downloaded" > $NORMAL_OUT
else
  SNAPSHOT_MANIFEST=$(echo $VERSION_MANIFEST_DATA | jq -r --arg VERSION_TARGET $VERSION_SNAPSHOT '.versions | .[] | select(.id==$VERSION_TARGET) | .url')
  echo "Downloading Package Manifest from: $SNAPSHOT_MANIFEST" > $NORMAL_OUT
  SNAPSHOT_MANIFEST_DATA=$(curl -s "$SNAPSHOT_MANIFEST")
  echo "Done" > $NORMAL_OUT
  echo "Parsing Package Manifest" > $NORMAL_OUT
  SNAPSHOT_NEWJAR_URL=$(jq -rn --argjson url "$SNAPSHOT_MANIFEST_DATA" '$url.downloads.server.url')
  SNAPSHOT_NEWJAR_SHA1=$(jq -rn --argjson sha1 "$SNAPSHOT_MANIFEST_DATA" '$sha1.downloads.server.sha1')
  echo "Done" > $NORMAL_OUT
  echo "Downloading snapshot jar" > $NORMAL_OUT
  curl -s -L -f -o $SNAPSHOT_JAR $SNAPSHOT_NEWJAR_URL
  echo "Done" > $NORMAL_OUT
  echo "Calculating SHA1 sum" > $NORMAL_OUT
  SNAPSHOT_SHA1=$(sha1sum $SNAPSHOT_JAR | cut -d " " -f 1 )
  if [ $SNAPSHOT_NEWJAR_SHA1 = $SNAPSHOT_SHA1 ]
  then
    echo "Hashes match" > $NORMAL_OUT
  else
    echo "Hashes mismatch - check jar file" > $ERROR_OUT
  fi
fi
