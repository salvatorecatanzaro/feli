
rgbasm -o main.o main.asm
if %errorlevel% neq 0 exit 1
rgblink -o hello-world.gbc main.o
rgbfix -C -v -p 0 hello-world.gbc

.\bgb_emulator\bgb.exe hello-world.gbc