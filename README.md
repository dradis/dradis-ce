# Welcome to Dradis

[![Build Status](https://secure.travis-ci.org/dradis/dradisframework.png)](https://secure.travis-ci.org/dradis/dradisframework)

Dradis is an open source collaboration framework, tailored to InfoSec teams.


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
  * [Retina](http://www.eeye.com/products/retina/retina-network-scanner)
  * [SureCheck](http://www.wildcroftsecurity.com/)
  * [VulnDB](http://vulndbhq.com)
  * [w3af](http://w3af.sourceforge.net/)
  * [wXf](https://github.com/WebExploitationFramework/wXf)
  * [Zed Attack Proxy](https://www.owasp.org/index.php/OWASP_Zed_Attack_Proxy_Project)


## Getting started (git release, recommended)

```
$ git clone https://github.com/dradis/dradisframework.git
$ cd dradisframework/
$ ruby bin/setup
$ bundle exec rails server
```

You can browse to the app at http://localhost:3000/



<!--On Debian-based operating systems (Ubuntu, BackTrack, etc.) use this script:

    $ bash < <(curl -s https://raw.github.com/dradis/meta/master/install.sh)

The script:
  1. Checks for system-level dependencies (git, openssl, etc.)
  2. Installs [RVM](http://beginrescueend.com/rvm/install/) and Ruby 1.9.3. It detects and reuses your existing RVM too.
  3. Downloads and prepares the git repo with Dradis code

[View install.sh source](https://github.com/dradis/meta/blob/master/install.sh)

If you want to manually clone the repo:

    $ mkdir dradis-git
    $ cd dradis-git/
    $ git clone https://github.com/dradis/dradisframework.git server

Then download the reset and start scripts to your dradis-git/ folder:

    $ curl -O https://raw.github.com/dradis/meta/master/reset.sh
    $ curl -O https://raw.github.com/dradis/meta/master/start.sh
    $ chmod +x *.sh
    $ ./reset.sh

Once the environment is ready, you can start the server with:

    $ ./start.sh

And browse to https://localhost:3004 to start using Dradis.

If you would like to make Dradis accessible to other people on the network:

    $ ./start.sh -b 0.0.0.0 -p 443

The `-b` option defines Dradis' bind address and the `-p` option can be used to change the port. -->


## Getting started (stable release)

In http://dradisframework.org/download.html you will find the latest packages. (pending 3.0 release)


<!-- Uncompress, verify and prepare the environment:

    $ tar xvvjf dradis-vX.Y.Z.tar.bz2
    $ cd dradis-vX.Y/
    $ ./verify.sh
      # follow instructions / install dependencies
    $ ./reset.sh

Once the environment is ready, you can start the server with:

    $ ./start.sh

And browse to https://localhost:3004 to start using Dradis. If you need to bind
to a different address (so others can connect to your instance) or another port
number, you can use the -b and -p switches respectively:

    $ ./start.sh -b 10.0.0.123 -p 443 -->


## Getting help

* http://dradisframework.org/
* Dradis Guides: http://guides.dradisframework.org
* [Community Forums](http://discuss.dradisframework.org/)
* IRC: **#dradis** `irc.freenode.org`


## Contributing

Please see CONTRIBUTING.md for details.

Many thanks to all Dradis Framework [contributors](https://github.com/dradis/dradisframework/graphs/contributors).


## License

Dradis Framework is released under [GNU General Public License version 2.0](http://www.gnu.org/licenses/old-licenses/gpl-2.0.html)
