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

After reading this sentence I quickly implemented the algorithm on
Haskell to check if it really works.

# My Implementation of the Algorithm #

For simplicity I implemented a linked list as a 1-based array of
integers. Each element of the array is a node of the linked list. And
each element contains just an index which points to the next element
of the list. Index 0 determines the end of the list.

    type LinkedList = Array Int Int

Let's define an operation for getting the next element in the list:

    next :: LinkedList -> Int -> Int
    next xs 0 = 0                   -- 0 is the end of the list. Not going anywhere.
    next xs i = xs ! i              -- Taking an index of the next element.

In the algorithm we have two pointers. One traverses the list two
nodes at a time, and one traverses the list one node at a time. Let's
define an operation for one step of the algorithm:

    nextTH :: LinkedList -> (Int, Int) -> (Int, Int)
    nextTH xs (t, h) = (next xs t, next xs $ next xs h)

And the last thing we need is to somehow determine if the algorithm
should stop. It should stop when the pointers to the same node:

    stop :: (Int, Int) -> Bool
    stop (t, h) = t == h

Alright, `nextTH` and `stop` is enough to implement cycle detection
algorithm. Since it involves a lot of function applications and I hate
Haskell's `($)` operator, I've defined this

    --- F#-like forward pipe operator
    (|>) :: a -> (a -> b) -> b
    x |> f = f x

F# programmers will understand me. :) Here is my implementation of the
algorithm:

    containsCycle :: LinkedList -> Bool
    containsCycle xs =  (1, 1)      -- Initial state of the pointers.
    
                     -- Traversing the list generating all possible states
                     -- of the pointers.
                     |> iterate (nextTH xs)
    
                     -- Since at the begining the pointers point to the
                     -- same node, we skip the first state.
                     |> tail
    
                     -- Drop all states until we find a stop state.
                     |> dropWhile (not . stop)
    
                     -- Take this state.
                     |> head
    
                     -- Take any pointer (doesn't matter which one, at the
                     -- stop state they are equal).
                     |> fst
    
                     -- If it is not 0 we found a cycle.
                     |> (/= 0)

Here is the
[complete source code](https://gist.github.com/rexim/5f623b0c183aa0503079). And
it seems to work. But why does it work?

# Why does it work? #

Here I've tried to prove the correctness of the algorithm. I'm not a
good mathematician or computer scientist, so I don't the Rigth Way to
do such things. But this proof is rather believable for me.

This is how a linked list with a cycle would look like:

<!-- Picture with a looped linked list -->

Eventually, the tortoise and hare pointers will start to walk only
with the loop.
