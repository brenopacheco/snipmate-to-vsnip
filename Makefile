#
# Makefile
# breno, 2020-10-25 18:49
#

VSNIP=./vsnip
SNIPMATE=./snipmate

SNIPPETS=$(wildcard $(SNIPMATE)/*.snippets)
JSON=$(SNIPPETS:$(SNIPMATE)/%.snippets=$(VSNIP)/%.json)

.PHONY: all clean scan
CFLAGS := -Wall -Wextra -Wpedantic -std=c99

all: lex scan

lex: lex.c
	@gcc lex.c -o lex $(CFLAGS)
	@rm lex.c

lex.c: lex.y
	@flex -o lex.c lex.y 

clean:
	rm -f lex.c
	rm -f $(VSNIP)/*

$(VSNIP)/%.json: $(SNIPMATE)/%.snippets
	cat $< | ./lex > $@

scan: lex $(SNIPMATE) $(JSON)

$(SNIPMATE): | $(VSNIP)
	@echo "Place your snipmate snippets in $(SNIPMATE)"

$(VSNIP):
	@mkdir $@
