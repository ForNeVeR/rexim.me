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
mark the visited nodes during traversing the list. And when we visit a
visited node we report that a cycle has been detected.
