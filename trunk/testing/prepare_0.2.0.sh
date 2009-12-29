#!/bin/bash

rm -rf securich
rm -rf securich.0.2.0
rm -rf securich.0.2.0.tar.gz
cp -rp /mysql/securich/securich securich.0.2.0
tar -cf securich.0.2.0.tar securich.0.2.0
gzip -9 securich.0.2.0.tar
