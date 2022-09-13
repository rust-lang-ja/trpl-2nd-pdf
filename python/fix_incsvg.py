#!/usr/bin/env python3
import re
import sys

for line in sys.stdin:
    line = line.rstrip()
    line = re.sub(r'\\includegraphics{img/ferris/(.*)}', r'\\def\\svgwidth{1in}\\input{\1.pdf_tex}', line)
    print(line)
