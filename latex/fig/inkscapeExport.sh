#!/bin/bash

# This script searches for svg files and then uses
# Inkscape to convert them to pdf for use in LaTeX
# Then PdfToPs to convert them to eps for use in dvips latex

svgFiles="*.svg"
for file in $svgFiles
do
	outFile="${file%%.*}.pdf"   # Replace .svg with .pdf
	inkscape -f $file -A $outFile   # Convert to pdf
	echo "Compiling $file to $outFile"   # Report back to user
done
