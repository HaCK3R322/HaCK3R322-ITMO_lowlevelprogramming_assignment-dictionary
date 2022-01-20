build_d: generate_d
run_d: generate_d execute_d
all_d: generate_d execute_d clean_d

build: generate
run: generate execute
all: generate execute clean


generate_d:
	@echo "----- generation:" 

	nasm -f elf64 -o out/lib.o src/lib/lib.asm
	nasm -f elf64 -o out/dict.o src/lib/dict.asm	
	nasm -f elf64 -o out/main.o src/main.asm
	ld out/lib.o out/dict.o out/main.o -o out/artifacts/main.elf

generate:
	@nasm -f elf64 -o out/lib.o src/lib/lib.asm
	@nasm -f elf64 -o out/dict.o src/lib/dict.asm	
	@nasm -f elf64 -o out/main.o src/main.asm
	@ld out/lib.o out/dict.o out/main.o -o out/artifacts/main.elf

execute_d:
	@echo "command: ld out/artifacts/main.elf && ./a.out"
	@echo "----- execution out:"
	@ld out/artifacts/main.elf && ./a.out
	@echo "\n----- end of execution."

execute:
	@ld out/artifacts/main.elf && ./a.out
	@echo

clean_d:
	rm out/*.o
	rm out/artifacts/main.elf
	@echo "----- all cleaned, now directory contains sourse-code only"

clean:
	@rm out/*.o
	@rm out/artifacts/main.elf
	
