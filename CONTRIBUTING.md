# How to contribute

Third-party patches are essential for keeping dradis great. We simply can't
access the huge number of platforms and myriad configurations for running
dradis. We want to keep it as easy as possible to contribute changes that
get things working in your environment. There are a few guidelines that we
need contributors to follow so that we can have a chance of keeping on
top of things.


## Getting Started

* Make sure you have a [GitHub account](https://github.com/signup/free)
* Submit a ticket for your issue, assuming one does not already exist.
  * Clearly describe the issue including steps to reproduce when it is a bug.
  * Make sure you fill in the earliest version that you know has the issue.
* Fork the repository on GitHub


## Making Changes

* Create a topic branch from where you want to base your work.
  * This is usually the master branch.
  * Only target release branches if you are certain your fix must be on that
    branch.
  * To quickly create a topic branch based on master; `git branch
    fix/master/my_contribution master` then checkout the new branch with `git
    checkout fix/master/my_contribution`.  Please avoid working directly on the
    `master` branch.
* Make commits of logical units.
* Check for unnecessary whitespace with `git diff --check` before committing.
* Make sure your commit messages are in the proper format.

````
    (#99999) Make the example in CONTRIBUTING imperative and concrete

    Without this patch applied the example commit message in the CONTRIBUTING
    document is not a concrete example.  This is a problem because the
    contributor is left to imagine what the commit message should look like
    based on a description rather than an example.  This patch fixes the
    problem by making the example concrete and imperative.

    The first line is a real life imperative statement with a ticket number
    from our issue tracker.  The body describes the behavior without the patch,
    why this is a problem, and how the patch fixes the problem when applied.

    If you need to add external references, here is how to do so.

    See:
      http://securityreactions.tumblr.com/post/31726556638/we-have-an-ids-and-a-waf
````

* Make sure you have added the necessary tests for your changes.
* Run _all_ the tests to assure nothing else was accidentally broken.

## Submitting Changes

* Review our [Contributor's Agreement](https://github.com/dradis/dradisframework/wiki/Contributor%27s-agreement). Sending us a pull request means you have read and accept to this agreement
* Push your changes to a topic branch in your fork of the repository.
* Submit a **pull request** to the repository in the dradis organization.
* Include a link to the pull request in the ticket


# Additional Resources

* [Contributor License Agreement](https://github.com/dradis/dradisframework/wiki/Contributor%27s-agreement)
* [General GitHub documentation](http://help.github.com/)
* [GitHub pull request documentation](http://help.github.com/send-pull-requests/)
* **#dradis** IRC channel on freenode.org
* [dradis-devel](https://lists.sourceforge.net/mailman/listinfo/dradis-devel) development mailing list
* Dradis Guides: http://guides.dradisframework.org
* [Community Forums](http://dradisframework.org/community/)
