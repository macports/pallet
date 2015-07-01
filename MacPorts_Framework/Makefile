CC = gcc
SOURCES = $(*.m *.c)
FRAMEWORKS = -framework Foundation -framework AppKit -framework Cocoa -framework SenTestingKit -framework MacPorts -framework Growl
LIBRARIES = -lobjc
INCLUDE_FLAGS = -I/opt/local/libexec/macports/include -L/opt/local/libexec/macports/lib -ltcl8.5
CFLAGS = -Wall -arch i386 -g -v $(SOURCES)
LDFLAGS = $(LIBRARIES) $(FRAMEWORKS) $(INCLUDE_FLAGS)
OUT = -o Build/main

all: $(SOURCES) $(OUT)

$(OUT): $(OBJECTS)
	$(CC) -o $(OBJECTS) $@ $(CFLAGS) $(LDFLAGS) $(OUT)

.m.o:
	$(CC) -c -Wall $< -o $@

clean: 
	$(RM) *.o *.gch *.swp .DS_Store main interp



