#!/bin/bash

rm -rf securich
rm -rf securich.0.2.1
rm -rf securich.0.2.1.tar.gz
cp -rp /mysql/securich/securich securich.0.2.1
tar -cf securich.0.2.1.tar securich.0.2.1
gzip -9 securich.0.2.1.tar
