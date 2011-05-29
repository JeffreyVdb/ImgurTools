PROGNAME = imgerl
PREFIX = /usr
INST_DIR = $(PREFIX)/bin
DOC_DIR = $(PREFIX)/share/doc/$(PROGNAME)

all: $(PROGNAME)

$(PROGNAME): imgerl.pl documentation.pod
	cp imgerl.pl $(PROGNAME)

.PHONY: install clean

install:
	-mkdir -p $(INST_DIR)
	install -m 0755 $(PROGNAME)	$(INST_DIR)
	-mkdir -p $(DOC_DIR)
	install -m 0644 documentation.pod $(DOC_DIR)

clean:
	@echo 'Nothing to clean'
