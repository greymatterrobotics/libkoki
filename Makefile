CFLAGS+=-g -Wall -O2 -std=c99
LDFLAGS+=-L./lib -lkoki
INCLUDES+=-I. -I./include

OBJECTS=labelling.o contour.o quad.o pca.o marker.o unwarp.o code_grid.o

SRC_DIR=./src
LIB_DIR=./lib
TEST_DIR=./test
DOCS_DIR=./docs
BUGS_DIR=./bugs
BUGS_HTML_DIR=$(BUGS_DIR)/html
TOOLS_DIR=./tools

CFLAGS+=`pkg-config --cflags glib-2.0 opencv`
LDFLAGS+=`pkg-config --libs glib-2.0 opencv`

all: solib examples docs docs_latex bugs_html AUTHORS

%.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) $(LDFLAGS) $(INCLUDES) -c $< -o $@

solib: $(OBJECTS)
	mkdir -p $(LIB_DIR)
	$(CC) -shared -Wl,-soname,libkoki.so \
		-o $(LIB_DIR)/libkoki.so $(OBJECTS)

examples: solib
	$(CC) $(CFLAGS) $(LDFLAGS) $(INCLUDES) \
		$(TEST_DIR)/example.c -o $(TEST_DIR)/example
	$(CC) $(CFLAGS) $(LDFLAGS) $(INCLUDES) \
		$(TEST_DIR)/realtime.c -o $(TEST_DIR)/realtime

run_example:
	LD_LIBRARY_PATH=$(LD_LIBRARY_PATH):$(LIB_DIR) \
		$(TEST_DIR)/example

run_example_realtime:
	LD_LIBRARY_PATH=$(LD_LIBRARY_PATH):$(LIB_DIR) \
		$(TEST_DIR)/realtime

docs:
	doxygen $(DOCS_DIR)/Doxyfile

docs_latex: docs
	cd $(DOCS_DIR)/latex ; make

bugs_html:
	ditz html $(BUGS_HTML_DIR)

AUTHORS:
	cd $(TOOLS_DIR) ; make AUTHORS

clean:
	rm -rf $(LIB_DIR) *.o
	rm -rf $(DOCS_DIR)/html $(DOCS_DIR)/latex
	rm -rf $(BUGS_HTML_DIR)
	rm -rf AUTHORS
	rm -rf $(TEST_DIR)/example $(TEST_DIR)/realtime

.PHONY: clean solib examples run_example run_example_realtime docs docs_latex bugs_html AUTHORS
