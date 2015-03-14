# Introduction #

Typically for this project, development is done in Trunk. So far, we have not had reason to use any branches - probably something to do with the number of developers on this project :)

build.properties specifies the version number which takes one of three forms:

  1. Stable Release: 1.0.0
  1. Beta: 1.0.0b1 (the first beta on the way towards releasing 1.0.0)
  1. Development: 1.0.0dev (development towards 1.0.0 in progress - this form should almost always be the one in Trunk)

When we tag the code, the version number should be one of the first two forms. As we develop (make changes to the code) the third form is used.

# Version format #

Here is a typical life cycle of the version from one stable release to the next:

  * 1.0.0
  * 1.0.1dev
  * 1.0.1b1
  * 1.0.1dev
  * 1.0.1b2
  * 1.0.1dev
  * 1.0.1b3
  * 1.0.1dev (after some time, we confirm that this version is stable enough to release)
  * 1.0.1

# How to make a new release #

Here's a more detailed example - here, we are making a very simple change to 1.0.0:

  1. Ensure that the current version is 1.0.1dev
  1. Make the change and commit to SVN
  1. Test, test and then test some more.
  1. Change the version to 1.0.1b1
  1. Tag the current code in Trunk as: https://transcriptstudio4isha.googlecode.com/svn/tags/1.0.1b1
> > (to do this in Flex Builder, right-click on the TranscriptStudio folder -> Team -> Branch/Tag... (Head Version of the Repository). Mention the change in the commit comment)
  1. Change the version to 1.0.1dev
  1. Do some more testing, this time on the new Tag rather than Trunk. Maybe test on another machine, or get another developer to test.
  1. When, after some time, its clear that the new tag is good, change the version to 1.0.1
  1. Tag the current code in Trunk (actually, better to tag the code in the 1.0.1b1 tag but make sure you remember to change the version number so its no longer beta) as: 1.0.1
  1. Change the version to 1.0.2dev

The last step is there because should someone make changes in trunk, we don't want those changes to look like they are a part of the latest stable release.

# Downloads #

When we do a stable release we should also make the distribution files available for download.

These files are automatically generated using the build.sh/build.bat scripts. Both scripts generate linux and Windows distributions. However, just to be sure, we should always build on the same environment (we'll use linux). Also its probably a good idea to make a note of which version of Flex SDK, exist DB, J2SE SDK etc was used.