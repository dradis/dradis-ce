# Dradis Community Edition

**Open-source pentest reporting and collaboration, free since 2007.**

[![CI](https://github.com/dradis/dradis-ce/actions/workflows/ci.yml/badge.svg)](https://github.com/dradis/dradis-ce/actions/workflows/ci.yml)
[![@dradisfw on X](https://img.shields.io/twitter/follow/dradisfw?style=social)](https://x.com/dradisfw)

Dradis Community Edition (CE) is an open-source pentest reporting tool you run on your own laptop or server. Everything from an engagement goes into one project: output from Burp Suite, Nessus, Nmap and other scanners, the findings you confirmed by hand, the screenshots and evidence next to them, and your methodology checklist. When you're done, export the report. It's free under GPLv2.

Run it on a laptop and the whole project goes where you go: the office, the client site, the secure data center. It doesn't need outside connectivity at any of them.

Try the [Dradis Sandbox](https://dradis.new). It's a **public** instance that self-destroys every 20 minutes.


## What Dradis Framework is known for

* **One project per engagement.** Scans, notes and evidence stay together, so you aren't copying from last month's report.
* **QA before anything ships.** Every issue and piece of evidence is marked Draft, Ready for Review or Published, so a reviewer can see what's checked and what isn't.
* **Risk scoring built in.** CVSS, DREAD, MITRE, STRIDE and AIVSS-SSVC calculators.
* **Reports from your own templates.** Export HTML, CSV or [PDF](https://github.com/dradis/dradis-pdf_export), or write an export add-on for any other format.
* **A REST API.** Read and write issues, evidence and notes from your own scripts and tools. [Agent skills](https://github.com/dradis/dradis-skills/).
* **Runs on any OS.** No two testers use the same one.


## Import your scanner output

This repo bundles upload add-ons for Acunetix, AppSpider (NTOSpider), Brakeman, Burp Suite, Core Impact, Metasploit, Nessus, Netsparker, Nexpose, Nikto, Nipper, Nmap, OpenVAS, Pentera, Qualys, SAINT, Veracode, WPScan and ZAP, plus a CSV importer for everything else.

See every tool Dradis works with on the [integrations page](https://dradis.com/integrations/).

Using an in-house scanner? Use the [universal CSV importer](https://github.com/dradis/dradis-csv), or you can [write your own upload add-on](https://dradis.com/ce/documentation/upload_add-on.html).


## Dradis Echo: AI context layer with data privacy built-in

The [Echo engine](./engines/dradis-echo), the Dradis AI context layer is bundled with the framework. It suggests text for a finding, and the tester decides whether to use it.

Where your findings go depends on the AI provider you connect:

* **Ollama (local model):** Echo calls no external API, so nothing leaves your network. It works air-gapped.
* **Anthropic, Gemini or OpenAI:** your finding content is sent to that provider as part of each prompt.

More on [Dradis Echo](https://dradis.com/tools/echo.html).


## Install Dradis Community Edition (free)

### From Git (recommended)

Follow [Installing Dradis from Git](https://dradis.com/ce/documentation/install_git.html).

### Using Docker

Get the latest image:

```
docker image pull dradis/dradis-ce:latest
```

Then run the container:

```
docker run -it -p 3000:80 dradis/dradis-ce
```

### On Kali Linux

Dradis is bundled in Kali Linux, BlackArch and ArchStrike. See [Installing Dradis on Kali](https://dradis.com/ce/documentation/install_kali.html).


### In the cloud

<a href="https://heroku.com/deploy?template=https://github.com/dradis/dradis-ce/tree/develop" target="_blank"><img src="https://www.herokucdn.com/deploy/button.svg" height="40"></a>
<a href="https://cloud.digitalocean.com/apps/new?repo=https://github.com/dradis/dradis-ce/tree/develop" target="_blank"><img src="https://www.deploytodo.com/do-btn-blue.svg" height="40"></a>

Deploy your own instance (you'll need an account with the cloud provider).


### Development Containers
Dradis comes preconfigured to develop in a [Development Container](https://containers.dev/)

If you use VS Code, install the `Dev Containers` extension. Otherwise, build and start the containers by pointing Docker Compose at the `compose.yaml` file in the `/.devcontainer` directory:

```
docker compose -f .devcontainer/compose.yaml up --build -d
```


## Word report template customization in Dradis Pro

Dradis Pro started in 2010 and is built on this Community Edition and adds what a consultancy needs to deliver as a team:

* Word and Excel reports in your own template. Send us a report sample and we'll create the template from it and keep it up to date. On every plan.
* The Issue Library, Mappings Manager, and Rules Engine, so scanner output turns into your team's own write-ups.
* Gateway, a live view of findings for your clients, and, on Remediate and Enterprise, Jira, Azure DevOps and ServiceNow integrations.

Pro has a free trial for teams of three or more. See [report automation in Dradis Pro](https://dradis.com/solutions/reporting.html) and [pricing](https://dradis.com/pricing.html).


## Getting help

* [Support](https://dradis.com/support/)
* [Community forum](https://discuss.dradis.com/)


## Contributing

Please see CONTRIBUTING.md for details.

Many thanks to all Dradis Framework [contributors](https://github.com/dradis/dradis-ce/graphs/contributors). Dradis has been around since 2007, and in 2016 we had to do some nasty Git gymnastics resulting in a lot of the previous SVN + Git history no longer being available in the current repo. We haven't deleted it though, and we're still very much grateful for the work of our former [contributors](https://github.com/dradis/dradis-legacy/graphs/contributors).


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

If you love open source, Ruby on Rails and would like to have a lot of freedom and autonomy in your work, maybe you should consider [joining our team](https://dradis.com/careers.html) to make Dradis even better.
