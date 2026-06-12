# enapter-cloud-init tests

Developer/CI-only [bats](https://github.com/bats-core/bats-core) unit tests for
`../enapter-cloud-init.sh`. They are not referenced by the recipe, so `tests/`
never enters the image.

Run them in a container (no host tooling needed):

```sh
make test
```
