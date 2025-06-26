---
title: Turtle Bunting, A LOGO Vexillological Reader 
author: P. J. Carter
description: A booklet on programming in LOGO with example programs for creating various flags.
year: 1990
tags: [ LOGO, programming, decoration, workshop, flag, vexillology ]
archive_link: https://archive.org/details/peter-carter-turtle-bunting/
embed_link: https://archive.org/embed/peter-carter-turtle-bunting/
image: turtle-bunting.webp
alt: Cover of booklet showing flags of the world, black and white reproduction
license: 
editor_note: I am a fan of LOGO, its ethos, history and pedagogy. I teach LOGO in my course Drawing, Moving and Seeing with Code, and have had students read this resource. I like its writing style and approach.
---

Preliminary Edition

Harold Abelson, one of the 'fathers' of Logo, has stated, 'Programs are for people to
read, and only incidentally for machines to execute.!' Logo programs are therefore a
ldnd of literature, to be read to gain an insight into the solving of problems. You can
perhaps consider a program as a chapter, and a procedure as equivalent to a paragraph.
It follows that programs must be designed to be easy to read, with a clear structure,
concise logic and meaningful names.
In the examples that follow, each program is presented in a particular Logo version,
usually the one in which it was first written. Most of them are quite short, usually
less than a page. There will be some unfamiliar words, colour numbers, screen sizes
etc., although many of the primitives are described in an Appendix. In every case,
primitive names are in all capitals, names of defined procedures begin with capitals, and
variable names are in all lower case, to make them more easily distinguishable.
There is very little explanation: you will have to read, and work out for yourself, what
each procedure does, how it fits into the whole program, and how it sends or receives
values. What were the problems faced by the programmer(s)? Are the solutions, the
procedures, the best solutions? How would you improve on them?
As you read, remember that FD means FORWARD, and should be pronounced as such,
and the same is true of other abbreviations like RT, LT, PU, PD and so on. Some
procedures in this book have lines that are too long to fit across the page. A line that is
indented is continuing from the previous, as in this example:

```LOGO
TO Block :length :width
REPEAT :width / 2 [FD :length RT 90 FD 1 RT 90
FD :length LT 90 FD 1 LT 90]
END
```

In a conventional programming book there would be discussion of the process of
analysis, design, coding and validation, with pseudocode, structure charts and that sort
of thing. In this book there's very little of that (there's some in boxes) and you will
work in reverse: this is programming by example. Read a procedure, think about it,
and make sure you understand it before moving to the next
There are some questions about the flags themselves to keep you busy. At the very
least, you should find out what the shapes and colours signify on each flag.
I am indebted to a number of students for several of these programs, and their names
appear with their procedures.
Why vexillology? Flags are something humans have been using for centuries. They
have bright colours, and the designs are usually made up of simple shapes, rectangles,
triangles, stars and the like (look for the 'tool' procedures that draw them). The trick is
in fitting them all together logically. Of course, those colours and shapes are symbolic,
they have meanings. Logo procedures are like that too.
