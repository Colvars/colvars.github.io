#!/bin/sh

# Find anchors that correspond to LaTeX section labels as indicated by tex4ht
# comments and substitutes back the original LaTeX labels.

# Only labels that are called by actual \refs are detected; for this reason, a
# special HTML tag <selfref> is added in the LaTeX source, and removed later
# by the script remove_selfrefs.py.

for i in *.html
do
  grep '^href=.*tex4ht:ref:' $i | \
  sed 's/href="#\(.*\)">.*<!--tex4ht:ref: \(.*\) --><\/a>.*/s\/"\1"\/"\2"\//' | \
  awk 'BEGIN {printf "\"{ "} {printf $0 " ; "} END {printf " }\""}' | \
  xargs sed -i $i -e

  sed -i 's/<title><\/title>/<title>Collective Variables Module - Reference Manual<\/title>/' $i

  python ../remove_htmltags.py $i selfref
done
