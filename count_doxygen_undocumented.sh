
rm -rf doxygen/html/*
make doxygen > log 2> err
grep 'not documented' err | cut -d ':' -f 1 | sort|  uniq -c | sort -rn
