# Echo: AI copilot for Dradis

The add-on requires [Dradis CE](https://dradis.com/ce/) > 4.0, or [Dradis Pro](https://dradis.com/).

It uses a local [Ollama](https://ollama.org/) installation to connect Dradis to
your preferred LLMs.

Dradis Echo ships with a flexible prompting engine that uses Liquid templates
to provide full context about your project and findings, so you can craft
relevant prompts to get the most accurate answers.

By default, Echo is configured to use this Ollama config:

```
Address: http://localhost:11434
Model: deepseek-r1:latest
```

This can be configured in app:
- CE: Settings -> Configure Integrations
- Pro: Tools -> Tool Manager -> Configure (in the Echo section)

Run Ollama and pull one of the models:

```bash
ollama pull deepseek-r1:latest
```

Make sure Redis is also running.


## Install

Add this to your `Gemfile.plugins`:

    gem 'dradis-echo'

And

    bundle install

Restart your Dradis server, and you should be good to go.

## Enable
While Echo is in Beta, it is disabled by default. To enable and start using Echo:
- CE: In the rails console, run `Dradis::Plugins::Echo::Engine.enable!`
- Pro: Tools -> Tool Manager -> Enable (in the Echo section)

## More information

See the Dradis Framework's [README.md](https://github.com/dradis/dradis-ce/blob/develop/README.md)


## Contributing

See the Dradis Framework's [CONTRIBUTING.md](https://github.com/dradis/dradis-ce/blob/develop/CONTRIBUTING.md)


## License

Dradis Framework and all its components are released under [GNU General Public License version 2.0](http://www.gnu.org/licenses/old-licenses/gpl-2.0.html) as published by the Free Software Foundation and appearing in the file LICENSE included in the packaging of this file.


## Feature requests and bugs

Please use the [Dradis Framework issue tracker](https://github.com/dradis/dradis-ce/issues) for add-on improvements and bug reports.
