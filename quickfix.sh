#!/bin/bash
allowupdate=`/usr/local/bin/nems-info allowupdate`
if [[ $allowupdate == 1 ]]; then
  echo "Performing NEMS QuickFix..."
  echo "It's really just a fancy name: this may take a while."
  echo "Do not stop this script once it is running."
  printf "Please wait patiently."

  for run in {1..2}
  do

    printf "."

    # Create a copy of the update script to run
    cp /usr/local/share/nems/nems-scripts/update.sh /tmp/qf.sh

    # Run the copy
    /tmp/qf.sh > /dev/null 2>&1

  done
  rm /tmp/qf.sh
  echo " Done."
else
  echo "Updates are disabled in NEMS SST."
fi
