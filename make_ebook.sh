#!/bin/bash


function scrape {
	echo "scraping " $1
	ruby serial_scrape.rb -s $1 > ${1}.html
	ebook-convert ${1}.html ${1}.mobi --authors "John McCrae" --title "${1}" --max-toc-links 500
	rm ${1}.html
}

while getopts ":wtgpah" opt; do
	case $opt in
		w) scrape "worm"
		   exit 
		;;
		t) scrape "twig"
		   exit
		;;
		g) scrape "glowworm"
		   exit
		;;
		p) scrape "pact"
		   exit
		;;
		a) scrape "glowworm"
		   scrape "worm"
		   scrape "pact"
		   scrape "twig"
		   exit
		;;

		h) echo "options are: -a for all, -h for help, -p for pact, -t for twig, -w for worm -g for glowworm/ward" 
		exit 1
		;;
	esac
done
