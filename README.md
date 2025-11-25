# Echo: AI copilot for Dradis

Echo ships with a flexible prompting engine that uses Liquid templates to provide full context about your project and findings, so you can craft relevant prompts to get the most accurate answers. Your data always stays local to uphold data sovereignty.

## Prerequisites

The add-on requires [Dradis CE](https://dradis.com/ce/) > 4.0, or [Dradis Pro](https://dradis.com/).

It uses a local [Ollama](https://ollama.org/) installation to connect Dradis to your preferred LLMs.

## Setup

Run Ollama and pull one of the models:

```bash
ollama serve
ollama run deepseek-r1:latest
```

If you are using the CE edition, you'll need to run Redis.

```bash
redis-server
```

And you'll need to update [this line](https://github.com/dradis/dradis-ce/blob/develop/config/cable.yml#L2) to 
```
adapter: redis
```

## Install

Add this to your `Gemfile.plugins`:

    gem 'dradis-echo', github: 'dradis/dradis-echo'

And

    bundle install

Lastly, restart your Dradis server, and you should see Echo available in your instance.

## Configure
Configure Echo with the Ollama server address and selected model:
- CE: Settings -> Configure Integrations
- Pro: Tools -> Tool Manager -> Configure (in the Echo section)

## More information

See the Dradis Framework's [README.md](https://github.com/dradis/dradis-ce/blob/develop/README.md)

## Contributing

See the Dradis Framework's [CONTRIBUTING.md](https://github.com/dradis/dradis-ce/blob/develop/CONTRIBUTING.md)

## License

Dradis Framework and all its components are released under [GNU General Public License version 2.0](http://www.gnu.org/licenses/old-licenses/gpl-2.0.html) as published by the Free Software Foundation and appearing in the file LICENSE included in the packaging of this file.

## Feature requests and bugs

Please use the [Dradis Framework issue tracker](https://github.com/dradis/dradis-ce/issues) for add-on improvements and bug reports.
