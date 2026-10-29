# Contributing

CHASE is open source, under the BSD 3-Clause License, and contributions are
welcome: reports of bugs, questions, demos, documentation, and code. The
full guide is
[CONTRIBUTING.md](https://github.com/chase-cps/chase/blob/master/CONTRIBUTING.md)
in the repository of CHASE.

## Reporting a bug or asking a question

Open an issue on [chase-cps/chase](https://github.com/chase-cps/chase/issues),
with the version (`chase-cps --version`), the back ends found
(`chase-cps doctor`), the smallest specification or script that shows the
problem, what CHASE answered, and what you expected. A wrong verdict is the
most serious kind of bug: please report it even if you are not sure.

## Proposing a change

1. For anything larger than a fix, open an issue first, so that we can agree
   on the design and the names.
2. Make the change on a branch, with tests: for a change to the contract
   algebra or to a check, a property test that compares it with its
   definition.
3. Update the documentation and the changelog, and open a pull request. The
   CI builds and tests CHASE on Ubuntu and macOS, with AddressSanitizer, and
   runs the demos; it must pass.

The operations follow their definitions in the literature, and the names
are the terms of contract theory. The [repositories](repositories.md) page
says where each part of CHASE lives.
