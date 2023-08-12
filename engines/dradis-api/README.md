# Dradis HTTP API


This plugin provides an external HTTP API that you can use to query / publish data to your Dradis instance.


## Bumping the API version

Rewatch: http://railscasts.com/episodes/350-rest-api-versioning

- When we bump the API version, we copy everything from the previous version and
start making changes while leaving the originals untouched.
- This means the entire controllers/vX/ and views/vX folders.
- Initially it duplicates the code, but eventually the new version is going to
evolve over time, while the original version will remain a snapshot of the
functionality that's frozen in time.
- I think we can safely deprecate older API versions after 2 years. See the
comments in the v1 controllers/ files for guidance on what to include in the
deprecated files.
- You'll also need to duplicate the routes block, and update the :default route
constraint to point to the new version.
- You'll need to duplicate the request specs too.
- Update the engine's CHANGELOG w/ a list of the breaking changes.


## Links, licensing, etc.
See the main repo's [README.md](https://github.com/dradis/dradis-ce/blob/master/README.md)
