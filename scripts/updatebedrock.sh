#!/bin/sh

ZIP_PATH=/opt/minecraft/bedrock/zips
BEDROCK_DOWNLOAD_URL=https://minecraft.net/en-us/download/server/bedrock/
echo "Downloading Bedrock Server page" >&1
BEDROCK_DOWNLOAD_URL_DATA=$(curl -H "Accept-Encoding: identity" -H "Accept-Language: en" -s -L -A "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; BEDROCK-UPDATER)" https://minecraft.net/en-us/download/server/bedrock/)
echo "Done" >&1


RELEASE_URL=$(echo $BEDROCK_DOWNLOAD_URL_DATA | grep -o 'https://minecraft.azureedge.net/bin-linux/[^"]*')
RELEASE_FILE=$ZIP_PATH/${RELEASE_URL##*/}
$RELEASE_VERSION=$(awk -F'bedrock-server-\|.zip' '{print $2}')
# echo "Latest Release: " $(awk -F'bedrock-server-\|.zip' '{print $2}')
if [ -e $RELEASE_FILE ]
then
  echo "Latest release already downloaded" >&1
else
  echo "Downloading release zip" >&1
  curl -L -f -o $RELEASE_FILE $RELEASE_URL
  echo "Done" >&1
  echo ${RELEASE_URL##*/} > /opt/minecraft/bedrock/release.version
fi

PREVIEW_URL=$(echo $BEDROCK_DOWNLOAD_URL_DATA | grep -o 'https://minecraft.azureedge.net/bin-linux-preview/[^"]*')
PREVIEW_FILE=$ZIP_PATH/${PREVIEW_URL##*/}
if [ -e $PREVIEW_FILE ]
then
  echo "Latest preview already downloaded" >&1
else
  echo "Downloading preview release" >&1
  curl -L -f -o $PREVIEW_FILE $PREVIEW_URL
  echo "Done" >&1
  echo ${PREVIEW_URL##*/} > /opt/minecraft/bedrock/preview.version
fi
