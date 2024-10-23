#!/bin/sh

# Define the path for zip files and server download URL
ZIP_PATH=/opt/minecraft/bedrock/zips
BEDROCK_DOWNLOAD_URL=https://minecraft.net/en-us/download/server/bedrock/

# Download the Bedrock Server page
echo "Downloading Bedrock Server page from: $BEDROCK_DOWNLOAD_URL" >&1
BEDROCK_DOWNLOAD_URL_DATA=$(curl -H "Accept-Encoding: identity" -H "Accept-Language: en" -s -L -A "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; BEDROCK-UPDATER)" https://minecraft.net/en-us/download/server/bedrock/)
echo "Done" >&1

# Extract the release URL and download the release ZIP if not already present
RELEASE_URL=$(echo $BEDROCK_DOWNLOAD_URL_DATA | grep -o 'https://www.minecraft.net/bedrockdedicatedserver/bin-linux/[^"]*')
RELEASE_FILE=$ZIP_PATH/${RELEASE_URL##*/}
RELEASE_VERSION=${RELEASE_FILE##*r-}
RELEASE_VERSION=${RELEASE_VERSION%%.zip}
echo "Latest release version: "$RELEASE_VERSION
if [ -e $RELEASE_FILE ]; then
        echo "Latest release already downloaded" >&1
else
        echo "Downloading release zip" >&1
        curl -R -L -f -H "Accept-Encoding: identity" -H "Accept-Language: en" -s -L -A "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; BEDROCK-UPDATER)" -o $RELEASE_FILE $RELEASE_URL
        echo "Done" >&1
        echo ${RELEASE_URL##*/} > /opt/minecraft/bedrock/release.version
fi

# Extract the preview URL and download the preview release ZIP if not already present
PREVIEW_URL=$(echo $BEDROCK_DOWNLOAD_URL_DATA | grep -o 'https://www.minecraft.net/bedrockdedicatedserver/bin-linux-preview/[^"]*')
PREVIEW_FILE=$ZIP_PATH/${PREVIEW_URL##*/}
PREVIEW_VERSION=${PREVIEW_FILE##*r-}
PREVIEW_VERSION=${PREVIEW_VERSION%%.zip}
echo "Latest preview version: "$PREVIEW_VERSION
if [ -e $PREVIEW_FILE ]; then
        echo "Latest preview already downloaded" >&1
        # Update preview.version if needed
  	if cmp --silent -- /opt/minecraft/bedrock/release.version /opt/minecraft/bedrock/preview.version; then
  		echo "snapshot.version already updataed" >&1
    	else
     		echo $VERSION_RELEASE > /opt/minecraft/bedrock/preview.version
       		echo "snapshot.version updated" >&1
	fi
else
        echo "Downloading preview release" >&1
        curl -R -L -f -H "Accept-Encoding: identity" -H "Accept-Language: en" -s -L -A "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; BEDROCK-UPDATER)" -o  $PREVIEW_FILE $PREVIEW_URL
        echo "Done" >&1
        echo ${PREVIEW_URL##*/} > /opt/minecraft/bedrock/preview.version
fi
