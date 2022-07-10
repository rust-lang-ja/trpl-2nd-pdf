#!/bin/bash

set -ex

# Clone Markdown source
if [[ -d "./book-ja" ]]; then
  cd book-ja
  git checkout master-ja
  git pull origin master-ja
else
  git clone https://github.com/rust-lang-ja/book-ja
  cd book-ja  
  git fetch
  git checkout master-ja
fi

# Build completely markdown files
echo $'\n[output.markdown]' >> book.toml
cat book.toml
/root/.cargo/bin/mdbook build

# Back to the root directory
cd ..

# Download online images
cp -r ./book-ja/src/img ./
for f in ./img/*.svg
do
  if [[ $f =~ \./img/(.*)\.svg ]]; then
    SVG=`pwd`/img/${BASH_REMATCH[1]}.svg
    PDF=`pwd`/${BASH_REMATCH[1]}.pdf
    PDFTEX=`pwd`/${BASH_REMATCH[1]}.pdf_tex
    inkscape -D "$SVG" --export-filename="$PDF" --export-latex
    PAGES=$(egrep -a '/Type /Page\b' "$PDF" | wc -l | tr -d ' ')
    python3 ./python/fix_pdf_tex.py "$PAGES" < "$PDFTEX" > "$PDFTEX.tmp"
    mv "$PDFTEX.tmp" "$PDFTEX"
  fi
done

# Make working directory
if [[ ! -d "./target" ]]; then
  mkdir target
fi

# Copy markdown files to the working directory
for f in ./book-ja/src/*.md; do
  cp "$f" target/
done

python3 python/fix_table.py < target/appendix-02-operators.md > target/tmp.md
mv target/tmp.md target/appendix-02-operators.md

for f in target/*.md; do
  BASE=$(basename $f .md)
  FILTERS="--filter ./python/filter.py"
  if [[ $BASE =~ appendix-02- ]]; then
    COLUMNS="--columns=10"
  fi
  FILENAME="$BASE" pandoc -o "./target/$BASE.tex" -f markdown_github+footnotes+header_attributes-hard_line_breaks \
      --pdf-engine=lualatex --top-level-division=chapter $COLUMNS --listings $FILTERS $f
done

python3 ./python/body.py < ./target/SUMMARY.md > body.tex
