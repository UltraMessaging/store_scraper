#!/bin/sh
# store_scraper.sh - see https://github.com/UltraMessaging/store_scraper
#
# Copyright (c) 2022 Informatica Corporation
# Permission is granted to licensees to use or alter this software for any
# purpose, including commercial applications, according to the terms laid
# out in the Software License Agreement.
#
# This source code example is provided by Informatica for educational
# and evaluation purposes only.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND INFORMATICA DISCLAIMS ALL WARRANTIES 
# EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION, ANY IMPLIED WARRANTIES OF 
# NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR A PARTICULAR 
# PURPOSE.  INFORMATICA DOES NOT WARRANT THAT USE OF THE SOFTWARE WILL BE 
# UNINTERRUPTED OR ERROR-FREE.  INFORMATICA SHALL NOT, UNDER ANY CIRCUMSTANCES,
# BE LIABLE TO LICENSEE FOR LOST PROFITS, CONSEQUENTIAL, INCIDENTAL, SPECIAL OR 
# INDIRECT DAMAGES ARISING OUT OF OR RELATED TO THIS AGREEMENT OR THE 
# TRANSACTIONS CONTEMPLATED HEREUNDER, EVEN IF INFORMATICA HAS BEEN APPRISED OF 
# THE LIKELIHOOD OF SUCH DAMAGES.


W="$1"
if [ -z "$W" ]; then :
  echo "Usage: store_scaper.sh webmon_url"
  echo "Example: ./store_scaper.sh http://127.0.0.1:12000"
  exit
fi

# Test store webmon.
if curl -s $W >/dev/null; then :
  sleep .1
else :
  echo "curl failed to access $W/stores" >&1
  exit 1
fi

# Get list of Stores in the process.
curl -s $W/stores >curl.stores
sleep .1
STORES=`perl -nlae 'if (/>Store \d+:<A HREF="([^"]+)"/){print "$1";}' curl.stores`

for S in $STORES; do :
  curl -s $W/$S > curl.store
  sleep .1
  STORE=`perl -nlae 'if (/H3>Store \d+: ([^<]+)</){print "$1";}' curl.store`
  # Get list of sources (by registration ID) registered with the Store.
  IDS=`perl -nlae 'while (s/(LI>"[^"]+" - +)<A HREF="([^"]+)">[^\/]+\/A> /$1/){print "$2";}' curl.store`
  echo "Store $STORE"

  for ID in $IDS; do :
    curl -s $W/$ID >curl.src
    SYNC=`perl -nlae 'if (/LI>Sync: \[([^\]]+)\]/){print "$1";}' curl.src`
    sleep .1
    TOPIC=`perl -nlae 'if (/DD>Topic: "([^"]+)"/){print "$1";}' curl.src`
    REGID=`perl -nlae 'if (/H3>(\d+):/){print "$1"}' curl.src`
    SRCCTX=`perl -nlae 'if (/H3>\d+: Source \[\d+ ([^ ]+) /){print "$1"}' curl.src`
    TRANSP=`perl -nlae 'if (/DD>LBM Stats: \[([^\]]+)\]/){print "$1"}' curl.src`
    SESSID=`perl -nlae 'if (/DD>Session ID: (\d+)/){print "$1";}' curl.src`
    echo "Store=$STORE Srcctx=$SRCCTX Transp=$TRANSP Topic=$TOPIC Regid=$REGID Sessid=$SESSID Sync=[$SYNC]"
  done
done
