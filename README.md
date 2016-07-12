# Welcome to the Dradis Framework

[ ![Build Status](https://codeship.com/projects/f06cef90-a1ae-0133-d7a5-465166e508dd/status?branch=master)](https://codeship.com/projects/128584)
[ ![Code quality](https://codeclimate.com/github/dradis/dradis-ce/badges/gpa.svg)](https://codeclimate.com/github/dradis/dradis-ce)
[ ![Black Hat Arsenal](https://www.toolswatch.org/badges/arsenal/2016.svg)](https://www.blackhat.com/us-16/arsenal.html#dradis-framework)

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
  * [Burp Scanner](http://portswigger.net/burp/scanner.html)
  * [Metasploit](http://www.metasploit.com/)
  * [Nessus](http://www.nessus.org/products/nessus)
  * [NeXpose](http://www.rapid7.com/products/nexpose-community-edition.jsp)
  * [Nikto](http://cirt.net/nikto2)
  * [Nmap](http://nmap.org)
  * [OpenVAS](http://www.openvas.org/)
  * [OSVDB](http://osvdb.org)
  * [Qualys](https://www.qualys.com/)
  * [Retina](http://www.eeye.com/products/retina/retina-network-scanner)
  * [SureCheck](http://www.wildcroftsecurity.com/)
  * [VulnDB](http://vulndbhq.com)
  * [w3af](http://w3af.sourceforge.net/)
  * [wXf](https://github.com/WebExploitationFramework/wXf)
  * [Zed Attack Proxy](https://www.owasp.org/index.php/OWASP_Zed_Attack_Proxy_Project)
  * ...
  * [Full list](http://dradisframework.org/addons/)


## Editions

There are two editions of Dradis Framework:

* **Dradis Framework Community Edition (CE)**: open-source and available freely under the GPLv2 license.
* **Dradis Framework Professional Edition (Pro)**: includes extra features that are more useful for organizations dealing with bigger teams and multiple projects at a time. To use Pro and get official support please [become a subscriber](http://securityroots.com/dradispro/).


## Getting started: Community Edition

### Git release (recommended)

```
$ git clone https://github.com/dradis/dradis-ce.git
$ cd dradis-ce/
$ ruby bin/setup
$ bundle exec rails server
```

You can browse to the app at http://localhost:3000/


### Stable release

In http://dradisframework.org/download.html you will find the latest packages.


## Getting help

* http://dradisframework.org/
* [Community Forums](http://discuss.dradisframework.org/)
* [Slack channel](https://evening-hamlet-4416.herokuapp.com/)
* IRC: **#dradis** `irc.freenode.org`


## Contributing

Please see CONTRIBUTING.md for details.

Many thanks to all Dradis Framework [contributors](https://github.com/dradis/dradisframework-ce/graphs/contributors). Dradis has been around since 2007, and in 2016 we had to do some nasty Git gimnastics resulting in a lot of the previous SVN + Git history no longer being available in the current repo. We haven't deleted it though, and we're still very much grateful for the work of our former [contributors](https://github.com/dradis/dradis-legacy/graphs/contributors).


### Branching model
We're following Vincent Driessen's [A successful Git branching model](http://nvie.com/posts/a-successful-git-branching-model/) to try to keep things organized.

In this repo we will have: *master*, *develop*, *release-* and *hotfix-* branches.

If you need to work on a feature branch, fork the repo and work on your own copy. We can check it from there. Eventually you'll merge to your *develop* and back to origin's *develop*.


## License

Dradis Framework Community Edition is released under [GNU General Public License version 2.0](http://www.gnu.org/licenses/old-licenses/gpl-2.0.html)

Dradis Framework Professional Edition is released under a commercial license.


## We're hiring

If you love open source, Ruby on Rails and would like to have a lot of freedom and autonomy in your work, maybe you should consider [joining our team](http://securityroots.com/careers.html) to make Dradis even better.
