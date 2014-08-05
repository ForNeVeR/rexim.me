title: Tortoise and Hare
author: rexim
date: Tue, 05 Aug 2014 15:08:25 +0700
description: An explanation of the Tortoise and Hare algorithm.

Recently, I was reading a Rod Hilton's blog post about
[The Worst Programming Interview Question](http://www.nomachetejuggling.com/2014/06/24/the-worst-programming-interview-question/). The
question was

> Write a function that can detect a cycle in a linked list.

I completely agree with the author that this question is absolutely
useless for programming interviews. But in general, I really like such
questions. The first solution which came to my head was somehow to
mark the visited nodes during traversing the list (within the nodes or
in a separate data structure). And when we visit an already visited
node we report that the list has a cycle. I continued to read further
and Dr. Hilton mentioned so called tortoise-and-hare algorithm. It
looked like a well-known classical algorithm but, for my shame, I had
heard nothing about it.

The algorithm is pretty simple.

> You have two pointers at the head of your linked list, one traverses
> the list two nodes at a time, and one traverses the list one node at
> a time; if ever the pointers point to the same node, you have a
> cycle somewhere.

After reading this sentence I quickly implemented the algorithm in
Haskell to check if it really works.

# Implementation of the Algorithm #

...
