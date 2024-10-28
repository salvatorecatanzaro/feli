#!/bin/bash

rgbasm -o main.o main.asm

if [[ $? != 0 ]]; then
  echo "Error while compiling rgbasm"
  exit 1
fi
rgblink -m map -o feli.gbc main.o
rgbfix -C -v -p 0 feli.gbc
