.PHONY: all

all: eulerangles-512px.png

%.png: %.pdf
	convert -flatten -density 120 $^ $@

eulerangles-512px.png: eulerangles.pdf
	convert -flatten -resize 512x576 $^ $@
