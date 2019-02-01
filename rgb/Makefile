TARGET = HSV2RGB
CC = gcc
CFLAGS = -ggdb
LDFLAGS = -ggdb
$(TARGET): $(TARGET).o
	$(CC) $(LDFLAGS) -o $@ $^ -lm
.PHONY: clean
clean:
	$(RM) $(TARGET) $(TARGET).o
