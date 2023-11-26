#!/bin/sh

# location for storing server zip files
ZIP_PATH=/opt/minecraft/bedrock/zips
# webpage to download bedrock server zip files
BEDROCK_DOWNLOAD_URL=https://minecraft.net/en-us/download/server/bedrock/
# gets the webpage and stores the contents as a variable
BEDROCK_DOWNLOAD_URL_DATA=$(curl -H "Accept-Encoding: identity" -H "Accept-Language: en" -s -L -A "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; BEDROCK-UPDATER)" https://minecraft.net/en-us/download/server/bedrock/)

# parses webpage to get download link for the latest release zip file
RELEASE_URL=$(echo $BEDROCK_DOWNLOAD_URL_DATA | grep -o 'https://minecraft.azureedge.net/bin-linux/[^"]*')
# combines path and filename of the above url
RELEASE_FILE=$ZIP_PATH/${RELEASE_URL##*/}
# checks to see if the zip file already exists
if [ -e $RELEASE_FILE ]
then
# tells the user the file has already been downloaded
  echo "Latest release already downloaded"
else
  echo "Downloading release zip"
# downloads the release zip file
  curl -L -f -o $RELEASE_FILE $RELEASE_URL
  echo "Done"
fi

# parses webpage to get download link for the latest preview zip file
PREVIEW_URL=$(echo $BEDROCK_DOWNLOAD_URL_DATA | grep -o 'https://minecraft.azureedge.net/bin-linux-preview/[^"]*')
# combines path and filename of the above url
PREVIEW_FILE=$ZIP_PATH/${PREVIEW_URL##*/}
# checkes to see if the zip file already exists
if [ -e $PREVIEW_FILE ]
then
# tells the user the file has already been downloaded
  echo "Latest preview already downloaded"
else
  echo "Downloading"
# downloads the preview zip file
  curl -L -f -o $PREVIEW_FILE $PREVIEW_URL
  echo "Done"
fi
