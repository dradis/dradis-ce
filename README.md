# Welcome to the Dradis Framework

[ ![Build Status](https://codeship.com/projects/f06cef90-a1ae-0133-d7a5-465166e508dd/status?branch=master)](https://codeship.com/projects/128584)
[ ![Code quality](https://codeclimate.com/github/dradis/dradis-ce/badges/gpa.svg)](https://codeclimate.com/github/dradis/dradis-ce)
[ ![Black Hat Arsenal](https://www.toolswatch.org/badges/arsenal/2016.svg)](https://www.blackhat.com/us-16/arsenal.html#dradis-framework)
[ ![Rawsec's CyberSecurity Inventory](https://inventory.rawsec.ml/img/badges/Rawsec-inventoried-FF5050_flat.svg)](https://inventory.rawsec.ml/tools.html#Dradis)

Dradis is an open-source collaboration framework, tailored to InfoSec teams.


## Our goals

* Share the information effectively.
* Easy to use, easy to be adopted. Otherwise it would present little benefit over other systems.
* Flexible: with a powerful and simple extensions interface.
* Small and portable. You should be able to use it while on site (no outside connectivity). It should be OS independent (no two testers use the same OS).


## Some of the features:

* Platform independent
* Markup support for the notes: text styles, code blocks, images, links, etc.
* Integration with existing systems and tools:
  * [Brakeman](https://dradisframework.com/ce/addons/brakeman.html)
  * [Burp Suite](https://dradisframework.com/ce/addons/burp.html)
  * [MediaWiki](https://dradisframework.com/ce/addons/mediawiki.html)
  * [Metasploit](https://dradisframework.com/ce/addons/metasploit.html)
  * [Nessus](https://dradisframework.com/ce/addons/nessus.html)
  * [NeXpose](https://dradisframework.com/ce/addons/nexpose.html)
  * [Nikto](https://dradisframework.com/ce/addons/nikto.html)
  * [Nmap](https://dradisframework.com/ce/addons/nmap.html)
  * [OpenVAS](https://dradisframework.com/ce/addons/openvas.html)
  * [OSVDB](https://dradisframework.com/ce/addons/osvdb.html)
  * [Qualys](https://dradisframework.com/ce/addons/qualys.html)
  * [Retina](https://dradisframework.com/ce/addons/retina.html)
  * [SAINT](https://dradisframework.com/ce/addons/saint.html)
  * [SureCheck](https://dradisframework.com/ce/addons/surecheck.html)
  * [VulnDB](https://dradisframework.com/ce/addons/vulndb.html)
  * [w3af](https://dradisframework.com/ce/addons/w3af.html)
  * [wXf](https://dradisframework.com/ce/addons/wxf.html)
  * [Zed Attack Proxy](https://dradisframework.com/ce/addons/zap.html)
  * ...
  * [Full list](http://dradisframework.org/addons/)


## Editions

There are two editions of Dradis Framework:

* **Dradis Framework Community Edition (CE)**: open-source and available freely under the GPLv2 license.
* **Dradis Framework Professional Edition (Pro)**: includes extra features that are more useful for organizations dealing with bigger teams and multiple projects at a time. To use Pro and get official support please [become a subscriber](https://dradisframework.com/pro/).


## Getting started: Community Edition

### Git release (recommended)

```
$ git clone https://github.com/dradis/dradis-ce.git
$ cd dradis-ce/
$ ruby bin/setup
$ bundle exec rails server
```

You can browse to the app at http://localhost:3000/

### Using Vagrant

If you'd like to use dradis in Vagrant, you can use the included Vagrantfile.

```
# Clone the repo
git clone https://github.com/dradis/dradis-ce.git

# install/start the vagrant box
vagrant up
# ssh into the box
vagrant ssh

# install ruby in the vagrant box
cd /dradis/dradis-ce
rvm install "$(cat .ruby-version)"


# Then you can proceed with standard setup from within Vagrant
ruby bin/setup
# You'll need to tell the server to bind to 0.0.0.0 for port forwarding:
bundle exec rails server -b 0.0.0.0
```

### Stable release

In https://dradisframework.com/ce/download.html you will find the latest packages.


## Getting help

* http://dradisframework.org/
* [Community Forums](https://discuss.dradisframework.org/)
* [Slack channel](https://evening-hamlet-4416.herokuapp.com/)
* IRC: **#dradis** `irc.freenode.org`


## Contributing

Please see CONTRIBUTING.md for details.

Many thanks to all Dradis Framework [contributors](https://github.com/dradis/dradis-ce/graphs/contributors). Dradis has been around since 2007, and in 2016 we had to do some nasty Git gimnastics resulting in a lot of the previous SVN + Git history no longer being available in the current repo. We haven't deleted it though, and we're still very much grateful for the work of our former [contributors](https://github.com/dradis/dradis-legacy/graphs/contributors).


### Branching model
We're following Vincent Driessen's [A successful Git branching model](http://nvie.com/posts/a-successful-git-branching-model/) to try to keep things organized.

In this repo we will have: *master*, *develop*, *release-* and *hotfix-* branches.

If you need to work on a feature branch, fork the repo and work on your own copy. We can check it from there. Eventually you'll merge to your *develop* and back to origin's *develop*.


### Community Projects

* [check-user-pwned-dradis by GoVanguard](https://github.com/GoVanguard/check-user-pwned-dradis): Searches for compromised emails across data breaches and creates Dradis Issues
* [csv-data-import-dradis by GoVanguard](https://github.com/GoVanguard/csv-data-import-dradis): Imports Issues, Nodes, Evidence, and Notes from a CSV file into Dradis
* [PyDradis by Novacoast](https://github.com/ncatlabs/pydradis): Python wrapper for the Dradis REST API

Have you built a Dradis connector, add-on, or extension? Contact us so that we can feature it here.


## License

Dradis Framework Community Edition is released under [GNU General Public License version 2.0](http://www.gnu.org/licenses/old-licenses/gpl-2.0.html)

Dradis Framework Professional Edition is released under a commercial license.


## We're hiring

If you love open source, Ruby on Rails and would like to have a lot of freedom and autonomy in your work, maybe you should consider [joining our team](https://dradisframework.com/careers.html) to make Dradis even better.
