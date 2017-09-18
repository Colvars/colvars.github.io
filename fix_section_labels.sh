#!/bin/sh

# Find anchors that correspond to LaTeX section labels as indicated by tex4ht comments
# and substitutes back the original LaTeX labels
# Note: only labels that are called by actual \refs are detected

for i in *.html
do
  grep 'tex4ht:ref: sec:'  $i | \
  sed 's/href="#\(.*\)">.*<!--tex4ht:ref: sec:\(.*\) --><\/a>.*/s\/\1\/\2\//' | \
  awk 'BEGIN {printf "\"{ "} {printf $0 " ; "} END {printf " }\""}' | \
  xargs sed -i $i -e
done
