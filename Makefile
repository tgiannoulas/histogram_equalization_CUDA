CC = nvcc
CFLAGS = -O4 -Xcompiler -Wall
CODE_PATH = Code/
OUTOUT_PATH = Output/
C_OBJ = $(CODE_PATH)util.o $(CODE_PATH)contrast-enhancement.o $(CODE_PATH)histogram-equalization.o $(CODE_PATH)main.o
CU_OBJ = $(CODE_PATH)contrast-enhancement_GPU.o $(CODE_PATH)histogram-equalization_GPU.o

all: $(C_OBJ) $(CU_OBJ)
	$(CC) $(CFLAGS) $(C_OBJ) $(CU_OBJ) -o $(CODE_PATH)main

$(CODE_PATH)%.o: $(CODE_PATH)%.c
	$(CC) $(CFLAGS) -c $< -o $@

$(CODE_PATH)%.o: $(CODE_PATH)%.cu
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm $(C_OBJ)
	rm $(CU_OBJ)
	rm $(CODE_PATH)main
