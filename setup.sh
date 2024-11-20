#!/bin/bash

if ! command -v wget &> /dev/null || ! command -v unzip &> /dev/null || ! command -v java &> /dev/null; then
  echo "Installing prerequisites..."
  sudo apt update && sudo apt install -y wget unzip default-jdk
else
  echo "Prerequisites already installed."
fi

if [ ! -f "redis-rdb-cli-release.zip" ]; then
  echo "Downloading redis-rdb-cli..."
  wget -q https://github.com/leonchen83/redis-rdb-cli/releases/download/v0.9.6/redis-rdb-cli-release.zip
else
  echo "redis-rdb-cli-release.zip already downloaded."
fi

if [ ! -d "redis-rdb-cli" ]; then
  echo "Extracting redis-rdb-cli..."
  unzip -q redis-rdb-cli-release.zip -d redis-rdb-cli
else
  echo "redis-rdb-cli already extracted."
fi

read -p "Enter Redis URI: " redis_uri

dump_file=$(find . -maxdepth 1 -type f -name "*.dump" | head -n 1)
if [ -z "$dump_file" ]; then
  echo "No dump file found. Looking for .rdb files..."
  dump_file=$(find . -maxdepth 1 -type f -name "*.rdb" | head -n 1)
fi

if [ -n "$dump_file" ]; then
  echo "Using file: $dump_file"
  mv "$dump_file" dump.rdb
else
  echo "No valid dump or rdb file found."
  exit 1
fi

./redis-rdb-cli/redis-rdb-cli/bin/rmt -s dump.rdb -m "$redis_uri"
