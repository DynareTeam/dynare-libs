include target.inc

all: index.html
	scp index.html ${TARGET}

index.html: index.md
	pandoc index.md -s -o index.html
