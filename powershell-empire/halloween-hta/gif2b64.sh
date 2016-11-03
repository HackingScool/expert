#!/bin/bash

n="$#"
for f in $*
do
  ((n--))
   f="$f.gif"
   t="\"data:image/gif;base64,$(cat $f | base64)\""
   if [ $n -ne 0 ]; then
      t="$t,"
   fi
   echo $t
done
