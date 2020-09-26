#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys, re

def input_sections(sections):
    return '\n'.join(r'\input{./target/%s.tex}' % s for s in sections)

if __name__ == "__main__":
    front_matter_sections = []
    main_matter_sections = []
    back_matter_sections = []
    isComment = False

    for line in sys.stdin:
        if re.search(r'<!--', line):
            isComment = True
        elif isComment and re.search(r'-->', line):
            isComment = False
    
        r = re.search(r'\[.*\]\((.*)\.md\)$', line)
        if isComment or not r:
            continue
        src = r.group(1)
        if src == 'foreword' or src.startswith('ch00'):
            front_matter_sections.append(src)
        elif src.startswith('appendix'):
            back_matter_sections.append(src)
        else:
            main_matter_sections.append(src)

    print('\\frontmatter')
    print('\\setcounter{secnumdepth}{0}')
    print(input_sections(front_matter_sections))

    print('\\tableofcontents')

    print('\\mainmatter')
    print('\\setcounter{secnumdepth}{3}')
    print(input_sections(main_matter_sections))

    print('\\backmatter')
    print('\\setcounter{secnumdepth}{0}')
    print(input_sections(back_matter_sections))
