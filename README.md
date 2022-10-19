# Kaleidoscope
Commented Disassembly of  Li-Chen Wang's classic Kaleidoscope program for the Cromemco Dazzler

---

## What is/was Kaleidoscope

[Kaleidoscope](https://en.wikipedia.org/wiki/Li-Chen_Wang#Cromemco) is a rather tiny (127 Bytes) demo program for the [Cromemco Dazzler](https://en.wikipedia.org/wiki/Cromemco_Dazzler) by [Li-Chen Wang](https://en.wikipedia.org/wiki/Li-Chen_Wang). It displays a 64x64 colour graphic much like a mechanical/optical [kaleidoscope](https://en.wikipedia.org/wiki/Kaleidoscope) using the repetitive structure of the Dazzlers memroy. The program was sold by Cromemco as on its own for 15 USD on [paper tape](https://americanhistory.si.edu/collections/search/object/nmah_1423437) or later on floppy disk as part of their _DAZZLER Games_ pack at 95 USD.

Here an example what it might look like (*1):

![Exemplary Output](Kaleidoscope_CPP.gif)

## Historic Relevance

While Kaleidoscope might be considered more like a short demo for same new hardware, it had an amazing effect in its time - and honest, it's still catchy - which other program can claim to have slowed down trafic to a stand still on NYC's 5th Avenue? It may also have influenced some other well known programmers to write similar programs - like the [Low Res](https://en.wikipedia.org/wiki/Apple_II_graphics#Low-Resolution_(Lo-Res)_graphics) Kaleidoscope delivered as part of [COLOR DEMO](https://youtu.be/zF_LFsIni8Q) on the Apples [DOS 3.2 Disk](https://www.apple2history.org/history/ah14/#08) for the Apple II.

## Why Adding a Repository 40+ Years Later?

In early October 2022 Maury Markowitz [asked](https://retrocomputing.stackexchange.com/questions/25304) on [RetroComputing.SE](https://retrocomputing.stackexchange.com/) if there's some high level analysis for that program, as all he could find was a basic disassembly. I tried some Google-Fu, found are many sites mentioning Kaleidoscope, including a few [running some emulation](https://observablehq.com/@fil/kaleidoscope-1976) to show it's output (*1), but none offering a commented source or high level description - the only one [attempting to do so](https://www.quaxio.com/kaleidoscope_part1/) in 2020 [closed his blog](https://www.quaxio.com/last_post/) right before touching that part :(

Being curious (and a bit bored) I decided to take a look at the disassembly, resulting in what's found here.

A few hours after the [commented disassembly](Kaleidoscope.asm) was [linked](https://retrocomputing.stackexchange.com/a/25308/6659) on Retrocomputing.SE, [Spektre](https://retrocomputing.stackexchange.com/users/6868/spektre) posted a [C++ recreation](https://retrocomputing.stackexchange.com/a/25310/6659). A [copy](Kaleidoscope%20in%20CPP.md) is added with permission - might be a more pleasant reading to today's programmer than Assembler :)) 

## Further Reading

- ["Build the TV Dazzler"](http://www.bitsavers.org/pdf/cromemco/Dazzler_PE_Feb76.pdf) from February 1976 issue of Popular Elecronics (at Bitsavers)
- Dazzler as Interface Age's [Card of the Month](http://bitsavers.informatik.uni-stuttgart.de/pdf/interfaceAge/productReviews/1977-03_Cromemco_Dazzler.pdf) of March 1977 (at Bitsavers)
- [Cromemco Dazzler Instruction Manual](http://www.bitsavers.org/pdf/cromemco/Cromemco_Dazzler_Instruction_Manual_RevC_1976.pdf) Revision C of March 1976 (at Bitsavers)
- [TV-Dazzler advertisement](https://archive.org/details/CromemcoCatalogAugust1976/page/n3/mode/2up?view=theater) in the August 1976 Cromemco Catalogue (at Archive.Org). It includes pictures of their program offerings (on Paper tape :)).
- [The Cromemco Story](https://archive.org/details/IoNewsVolume1Number1/page/n5/mode/2up?view=theater), a 1980 article about the company's history (so far) in the IACO I/O News Vol.1 Issue.1 (at Archive.Org)

## Files (so far)

- [Disassembly Listing](Disassembly%20Listing) -> Disassembly Listing used as base to regenerate the source
- [Kaleidoscope.asm](Kaleidoscope.asm) -> Commented source listing of the Dazzler Kaleidoscope program
- [Kaleidoscope_Manual.png](Kaleidoscope_Manual.png) -> Kaleidoscope's 'manual' page from p.32 of the [Cromemco Dazzler Games Manual](http://www.bitsavers.org/pdf/cromemco/Cromemco_Dazzler_Games_1977.pdf) (at Bitsavers)
- [Kaleidoscope in CPP.md](Kaleidoscope%20in%20CPP.md) -> [Spektre](https://retrocomputing.stackexchange.com/users/6868/spektre)'s C++ recreation of Kaleidoscope 
- [Kaleidoscope_CPP.gif](Kaleidoscope_CPP.gif) -> Exemplary output using [Spektre](https://retrocomputing.stackexchange.com/users/6868/spektre)'s C++ recreation 
- README.md -> This file

---

*1 - Well, the [real output](https://www.youtube.com/watch?v=2tDbn1N8EWI) of a real Dazzler on a real CRT isn't as shiney and sterile as those modern browser implementations make it look:)) Also, the modern variant runs at about 2-3 times the original speed.
