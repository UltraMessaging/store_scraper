# store_scraper - Simple UM Store webmon scraper

This is a shell script that crawls an Ultra Messaging Store web monitor.

# Table of contents

- [store_scraper - Simple UM Store webmon scraper](#store_scraper---simple-um-store-webmon-scraper)
- [Table of contents](#table-of-contents)
  - [COPYRIGHT AND LICENSE](#copyright-and-license)
  - [REPOSITORY](#repository)
  - [store_scraper.sh](#store_scrapersh)
  - [Code Notes](#code-notes)

<sup>(table of contents from https://luciopaiva.com/markdown-toc/)</sup>

## COPYRIGHT AND LICENSE

All of the documentation and software included in this and any
other Informatica Ultra Messaging GitHub repository
Copyright (C) Informatica. All rights reserved.

Permission is granted to licensees to use
or alter this software for any purpose, including commercial applications,
according to the terms laid out in the Software License Agreement.

This source code example is provided by Informatica for educational
and evaluation purposes only.

THE SOFTWARE IS PROVIDED "AS IS" AND INFORMATICA DISCLAIMS ALL WARRANTIES
EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION, ANY IMPLIED WARRANTIES OF
NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR A PARTICULAR
PURPOSE.  INFORMATICA DOES NOT WARRANT THAT USE OF THE SOFTWARE WILL BE
UNINTERRUPTED OR ERROR-FREE.  INFORMATICA SHALL NOT, UNDER ANY CIRCUMSTANCES,
BE LIABLE TO LICENSEE FOR LOST PROFITS, CONSEQUENTIAL, INCIDENTAL, SPECIAL OR
INDIRECT DAMAGES ARISING OUT OF OR RELATED TO THIS AGREEMENT OR THE
TRANSACTIONS CONTEMPLATED HEREUNDER, EVEN IF INFORMATICA HAS BEEN APPRISED OF
THE LIKELIHOOD OF SUCH DAMAGES.

## REPOSITORY

See https://github.com/UltraMessaging/store_scraper for code and documentation.

## store_scraper.sh

This script has been tested with Linux.
You must have curl and perl installed.

Usage:

````
store_scraper.sh store_url
````

For example:
````
Store=null
Store=tst
Store=tst Srcctx=10.29.3.101.14394 Transp=LBTRM:10.29.3.101:14390:d5c07481:224.10.10.10:14400 Topic=tst Regid=1750475241 Sessid=0 Sync=[399, 399, 399]
Store=tst Srcctx=10.29.3.101.14395 Transp=LBTRM:10.29.3.101:14391:51c9610c:224.10.10.10:14400 Topic=tst Regid=1750475242 Sessid=0 Sync=[394, 394, 394]
````

## Code Notes

Note the "sleep .1" lines.
It is a bad idea to flood a UM Store with webmon requests.
The web monitor thread takes a lock during its operation which contents
with message processing.

There's a Perl command that may not be obvious:
````
  IDS=`perl -nlae 'while (s/(LI>"[^"]+" - +)<A HREF="([^"]+)">[^\/]+\/A> /$1/){print "$2";}' curl.store`
````
It uses a "while" loop and a substitute command, while the other Perl commands just use a simple "if" statement.
This is because there can be more than one registered source per topic,
and the per-source links are all on the same line.

So let's say that the input line is:
````
<UL><LI>"tst" -  <A HREF="/stores/1/1750475241">1750475241(0)</A>  <A HREF="/stores/1/1750475242">1750475242(0)</A> </UL>
````

The first loop will replace 'LI>"tst" -  <A HREF="/stores/1/1750475241">1750475241(0)</A>'
with 'LI>"tst" -  ' and print '/stores/1/1750475241', leaving the input line as this:
````
<UL><LI>"tst" -    <A HREF="/stores/1/1750475242">1750475242(0)</A> </UL>
````

The next loop will replace 'LI>"tst" -    <A HREF="/stores/1/1750475242">1750475242(0)</A>'
with 'LI>"tst" -  ' and print '/stores/1/1750475242', leaving the input line as this:
````
<UL><LI>"tst" -     </UL>
````

And the next loop will fail the substitute and exit the loop.