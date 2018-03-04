
## Development

```shell
# build & exec
$ stack exec -- yesod devel

# test
$ stack test --flag yesod-simple-bulma:library-only --flag yesod-simple-bulma:dev

# Add Handler
$ stack exec -- yesod add-handler -r ROUTE_NAME -p PATH_PATTERN -m METHOD
...

# Update app-static-dir
$ touch src/Settings/StaticFiles.hs
```
