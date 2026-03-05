This is a Rails Engine that configured Dradis in Sandbox mode as shown at https://sandbox.dradis.new.


## Development
To make Dradis run in Sandbox mode, run this in the terminal:

```ruby
bin/rails sandbox:enable
```

To go back to regular mode:

```ruby
bin/rails sandbox:disable
```

Then you can work in Dradis as usual. Alternatively use `SANDBOX=1` in your ENV.


## How to update Dradis

After making changes to this gem, you need to update Dradis to pick up the changes:

```ruby
BUNDLE_GEMFILE=Gemfile.sandbox bundle update --conservative dradis-sandbox
```


## Links, licensing, etc.
See the main repo's [README.md](https://github.com/dradis/dradis-ce/blob/master/README.md)
