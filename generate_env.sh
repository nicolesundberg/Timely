#!/bin/sh

if [ ! -d assets ]; then
  # Make the assets directory if it doesn't exist at top level
  mkdir assets
fi
cd assets
# Create the .env file inside the assets directory
cat > .env << EOF
APPLE_MAPS_API_KEY='$APPLE_MAPS_API_KEY'
GOOGLE_MAPS_API_KEY='$GOOGLE_MAPS_API_KEY'
OWM_API_KEY='$OWM_API_KEY'
EOF
cd /