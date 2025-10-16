#!/bin/sh
set -eu
cd "/workspace/final_tex_paper_in_this_folder"
pdflatex -interaction=nonstopmode paper.tex || true
bibtex paper || true
pdflatex -interaction=nonstopmode paper.tex || true
pdflatex -interaction=nonstopmode paper.tex || true
