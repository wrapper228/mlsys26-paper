#!/bin/sh
set -eu
cd "$(dirname "$0")"

pdflatex -interaction=nonstopmode paper.tex || true
bibtex paper || true
pdflatex -interaction=nonstopmode paper.tex || true
pdflatex -interaction=nonstopmode paper.tex || true

