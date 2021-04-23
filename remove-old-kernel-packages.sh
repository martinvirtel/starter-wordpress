#! /bin/bash

printf '# pipe this into sudo bash like so:\n\t'"$0"' | sudo bash\n\n'
dpkg -l | \
   egrep 'ii  linux-(image|modules|headers)[^ ]+[1-9].[1-9]+\.' | \
   awk '{print "dpkg --purge " $2 }' | \
   grep -v $(uname -r| sed -r 's/-[^\-]+$//')

