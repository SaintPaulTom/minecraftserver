#!/bin/sh

# Define the version manifest and JAR path
VERSION_MANIFEST='https://piston-meta.mojang.com/mc/game/version_manifest.json'
JAR_PATH=/opt/minecraft/java/jars

# Check if the directory exists, create if not
if [ -e /opt/minecraft/java/jars ]; then
	mkdir -p /opt/minecraft/java/jars
fi

#d Download the version manifest
echo "Downloading Version Manifest from: $VERSION_MANIFEST" >&1
VERSION_MANIFEST_DATA=$(curl -s "$VERSION_MANIFEST")

# Extract the latest release and snapshot version numbers
VERSION_RELEASE=$(echo "$VERSION_MANIFEST_DATA" | jq -r '.latest.release' )
VERSION_SNAPSHOT=$(echo "$VERSION_MANIFEST_DATA" | jq -r '.latest.snapshot' )

# Define the file paths for the JARs
RELEASE_JAR=$JAR_PATH/minecraft_server.$VERSION_RELEASE.jar
SNAPSHOT_JAR=$JAR_PATH/minecraft_server.$VERSION_SNAPSHOT.jar
echo "Done" >&1

# Check and download the latest release version
echo "Latest release version: $VERSION_RELEASE" >&1
if [ -e $RELEASE_JAR ]; then
	echo "Latest release already downloaded" >&1
else
	# Download and parse the release manifest and download the JAR file
	RELEASE_MANIFEST=$(echo $VERSION_MANIFEST_DATA | jq -r --arg VERSION_TARGET $VERSION_RELEASE '.versions | .[] | select(.id==$VERSION_TARGET) | .url')
	echo "Downloading Package Manifest from: $RELEASE_MANIFEST" >&1
	RELEASE_MANIFEST_DATA=$(curl -s "$RELEASE_MANIFEST")
	echo "Done" >&1
	echo "Parsing Package Manifest" >&1
	RELEASE_NEWJAR_URL=$(jq -rn --argjson url "$RELEASE_MANIFEST_DATA" '$url.downloads.server.url')
	RELEASE_NEWJAR_SHA1=$(jq -rn --argjson sha1 "$RELEASE_MANIFEST_DATA" '$sha1.downloads.server.sha1')
	echo "Done" >&1
	echo "Downloading release jar" >&1
	curl -R -L -f -o $RELEASE_JAR $RELEASE_NEWJAR_URL
	echo "Done" >&1
 	# Verify the SHA1 sum
	echo "Calculating SHA1 sum" >&1
	RELEASE_SHA1=$(sha1sum $RELEASE_JAR | cut -d " " -f 1 )
	if [ $RELEASE_NEWJAR_SHA1 = $RELEASE_SHA1 ]; then
		echo "Hashes match" >&1
		echo $VERSION_RELEASE > /opt/minecraft/java/release.version
	else
		echo "Hashes mismatch - check jar file" >&2
	fi
fi

# Check and download the latest snapshot version
echo "Latest snapshot version: $VERSION_SNAPSHOT" >&1
if [ -e $SNAPSHOT_JAR ]; then
	echo "Latest snapshot already downloaded" >&1
else
	# Download and parse the snapshot manifest and download the JAR file
	SNAPSHOT_MANIFEST=$(echo $VERSION_MANIFEST_DATA | jq -r --arg VERSION_TARGET $VERSION_SNAPSHOT '.versions | .[] | select(.id==$VERSION_TARGET) | .url')
	echo "Downloading Package Manifest from: $SNAPSHOT_MANIFEST" >&1
	SNAPSHOT_MANIFEST_DATA=$(curl -s "$SNAPSHOT_MANIFEST")
	echo "Done" >&1
	echo "Parsing Package Manifest" >&1
	SNAPSHOT_NEWJAR_URL=$(jq -rn --argjson url "$SNAPSHOT_MANIFEST_DATA" '$url.downloads.server.url')
	SNAPSHOT_NEWJAR_SHA1=$(jq -rn --argjson sha1 "$SNAPSHOT_MANIFEST_DATA" '$sha1.downloads.server.sha1')
	echo "Done" >&1
	echo "Downloading snapshot jar" >&1
	curl -R -L -f -o $SNAPSHOT_JAR $SNAPSHOT_NEWJAR_URL
	echo "Done" >&1
 	# Verify the SHA1 sum
	echo "Calculating SHA1 sum" >&1
	SNAPSHOT_SHA1=$(sha1sum $SNAPSHOT_JAR | cut -d " " -f 1 )
	if [ $SNAPSHOT_NEWJAR_SHA1 = $SNAPSHOT_SHA1 ]; then
		echo "Hashes match" >&1
		# Update snapshot version if same as release
  		echo $VERSION_SNAPSHOT > /opt/minecraft/java/snapshot.version
		if [ $VERSION_RELEASE = $VERSION_SNAPSHOT ]; then
			echo $VERSION_RELEASE > /opt/minecraft/java/snapshot.version
		fi
	else
		echo "Hashes mismatch - check jar file" >&2
	fi
fi


