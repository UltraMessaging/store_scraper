# store_scraper - Simple UM Store webmon scraper

This is a shell script that crawls an Ultra Messaging Store web monitor.

# Table of contents

- [store_scraper - Simple UM Store webmon scraper](#store_scraper---simple-um-store-webmon-scraper)
- [Table of contents](#table-of-contents)
  - [COPYRIGHT AND LICENSE](#copyright-and-license)
  - [REPOSITORY](#repository)
  - [Introduction](#introduction)
  - [Usage](#usage)
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

## Introduction

The store_scraper.sh tool is a fairly simple shell script that crawls an
Ultra Messaging Store web monitor and prints some summary information about
each source that is being persisted.
The intention is that this would be a starting place for a user to write
their own tool, extracting and printing more desired information.

You must have curl and perl installed.
This script has been tested with Linux and Mac.

## Usage

````
store_scraper.sh store_url
````

For example:
````
$ ./store_scraper.sh mamba.29west.com:12010
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

The Perl programs are run with "-nlae" flags, which are intended to make old Awk programmers feel more at home:
* -n basically wraps your program in an implied loop, reading each input line and running your code until end of file.
* -l performs a "chomp" on each input line (removing the newline) and also adds an implicit newline to each print.
* -a does an automatic "split" of the input line into the array "@F". (My programs don't actually use this.)
* -e tells Perl that the program is the next thing on the command line.

So consider the shell line:
````
STORES=`perl -nlae 'if (/>Store \d+:<A HREF="([^"]+)"/){print "$1";}' curl.stores`
````
This reads each line of "curl.stores", chomps it, and performs the "if" statement.

Here's a Perl command that is probably not clear:
````
  IDS=`perl -nlae 'while (s/(LI>"[^"]+" - +)<A HREF="([^"]+)">[^\/]+\/A> /$1/){print "$2";}' curl.store`
````
It uses a "while" loop and a substitute command because there can be more than one registered source per topic,
and the per-source links are all on the same line.
The "while" loops through the links, and the substitute makes sure the loop exits.

Let's say that the input line is this:
````
<UL><LI>"tst" -  <A HREF="/stores/1/1750475241">1750475241(0)</A>  <A HREF="/stores/1/1750475242">1750475242(0)</A> </UL>
````

The first loop will replace:
````
LI>"tst" -  <A HREF="/stores/1/1750475241">1750475241(0)</A>
````
with:
````
LI>"tst" -  
````
 and print '/stores/1/1750475241', leaving the input line as this:
````
<UL><LI>"tst" -    <A HREF="/stores/1/1750475242">1750475242(0)</A> </UL>
````

The next loop will replace:
````
LI>"tst" -    <A HREF="/stores/1/1750475242">1750475242(0)</A>
````
with
````
LI>"tst" -  
````
 and print '/stores/1/1750475242', leaving the input line as this:
````
<UL><LI>"tst" -     </UL>
````

And the next loop will fail the substitute and exit the loop.
