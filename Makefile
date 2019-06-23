# source path
SP = valacord

SRCS = $(SP)/valacord.vala $(SP)/http/https.vala $(SP)/http/api.vala $(SP)/http/endpoints.vala $(SP)/http/errors.vala
OBJS = $(addsuffix .c, $(basename $(SRCS)))

VLC = valac
GCC = gcc-9

VALFLAGS = --pkg=gio-2.0 --pkg soup-2.4 --pkg json-glib-1.0 --library valacord --basedir ./
GCCFLAGS = --shared -fPIC
PKGFLAGS = $(shell pkg-config --cflags --libs gobject-2.0) $(shell pkg-config --cflags --libs libsoup-2.4) $(shell pkg-config --cflags --libs json-glib-1.0)

libvalacord.so: $(SRCS)
	# output dir
	mkdir -p bin

	# parse
	$(VLC) -C -H valacord.h $(VALFLAGS) $(SRCS)
	# compile & link
	$(GCC) $(GCCFLAGS) $(PKGFLAGS) -o libvalacord.so $(OBJS)

	# install
	cp valacord.h tests/
	cp valacord.h bin/
	cp valcord.vapi bin/
	cp libvalacord.so bin/
	# clear
	rm $(OBJS)

test: valacord
	$(VLC) --pkg=gio-2.0 --pkg json-glib-1.0 -X -I. -X -L. -X -lvalacord -o test tests/test.vala valacord.vapi --basedir ./
	# --------------- EXECUTION ---------------
	LD_LIBRARY_PATH=$(PWD) G_MESSAGES_DEBUG=all ./test

clear:
	rm -rf bin
	rm valacord.vapi valacord.h libvalacord.so $(OBJS) tests/valacord.h test

.PHONY: clean
.PHONY: test