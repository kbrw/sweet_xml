Hi, and thank you for wanting to contribute.
This document is divided in two parts: one more philosophical, and one more practical. Both are important, but the practical part depends on the philosophical one, you are therefore warmly invited to read this document in full.
This document is not set in stone, and we will update it according to our experience over time.

# Core Principles

* Backward Compatibility:
  This is the most important value to Kbrw. Unless Elixir, Erlang, or Javascript brings an incompatible change, we strive as much as possible to keep our libraries stable, and backward compatible.
* Auditability:
  Regarding the library life-cycle, this means that we want to be able to follow the changes that happened through the git history. This has a few implications on what kind of change we accept or refuse, and how we want these changes to take form.

# How This Works in Practice

The first rule:
## Start with opening an issue.

Details what kind of error you are encountering, or what kind of feature you want to see added.
Describe how to reproduce the error, or how the feature would be used. Try to provide concrete examples of code.
If you want to bring the change yourself, please also describe how you would go about it:
* For correcting an error, details where the sources of the error are, why it causes an error, what you plan to change and how.
* For adding a feature, details where the code would be impacted, why you want to bring the change there, and how you came to this conclusion.
In either case, we will provide feedback, either a go ahead to create a PR to be reviewed, an extended discussion on how to approach the change differently, or a refusal.

The issue should be geared toward one and only one change, with as limited of a scope as possible.

## The PR itself

Try to make the least amount of change as possible. We will provide feedback if we see a way that can be done with less. Try also to fit it all in one commit, although if it's impossible for X or Y reason, try to do it so each commit keeps the lib functional, no broken intermediate state.
Once the inspection is all done and everything is accepted, we will squash the merge if necessary.

## Code formatting

If no `.formatter.exs` exists, please don't run `mix format` on the project. This will bring a lot of unnecessary changes. Likewise, please don't manually modify the code layout outside of your direct changes.
In other words, please keep the changes to a minimum.

## Refactoring

Please discuss this extensively with us before engaging yourself in this kind of change. We probably won't accept it if it's not done in order to facilitate one or more changes that you have in mind, or that you have already opened as an issue.

## What about non functional change ?

Keep it to the first rule, we can probably suggest something to make your contribution be more than changing two words in the comments.