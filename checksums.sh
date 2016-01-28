#!/bin/bash

echo -n "Generating new Checksums ... "

# Base Directory Scripts
# md5sum mcserver.sh > checksums
# End users do not need checksums.sh and developers use git
md5sum mcserver.sh > checksums

# Other Script Files
find .script/ -type f -exec md5sum "{}" \; >> checksums

echo "Done!"
