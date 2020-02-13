PROGRAM = makedep
C_SRCS  = makedep.c


all: $(PROGRAM)

clean:
	$(RM) $(PROGRAM) $(C_SRCS:.c=.o)


$(PROGRAM): $(C_SRCS:.c=.o)
	$(CC) -o $@ $<

.c.o:
	$(CC) -c -o $@ $<

makedep.o: list.h
