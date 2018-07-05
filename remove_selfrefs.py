#!/usr/bin/env python

from __future__ import print_function

import os
import sys
from bs4 import BeautifulSoup

html_file = open(sys.argv[1], 'r')
html = html_file.read()
html_file.close()

soup = BeautifulSoup(html, 'lxml')

for ref in soup('selfref'):
    ref.decompose()

html_file = open(sys.argv[1], 'w')
html_file.write(str(soup))
html_file.close()

