# E2E Grafana version resolver

This Action resolves what versions of Grafana to use when E2E testing a Grafana plugin in a Github Action.

## Features

The action supports two modes.

**plugin-grafana-dependency (default)**
The will return all the latest patch releases of Grafana since the version that was specified as grafanaDependency in the plugin.json. This requires the plugin.json file to be placed in the `<root>/src` directory.

**version-support-policy**
This will resolve versions according to Grafana's plugin compatibility support policy, meaning it will resolve all latest patch releases for the current major version and the last minor of the previous major version.

The output of the action is a json array of Grafana minor versions. These can be used to specify a version matrix in a subsequent workflow job. See examples below.

## Workflow example

### plugin-grafana-dependency

```yaml
name: E2E tests - Playwright
on:
  pull_request:

jobs:
  setup-matrix:
    runs-on: ubuntu-latest
    outputs:
      matrix: ${{ steps.resolve-versions.outputs.matrix }}
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      - name: Resolve Grafana E2E versions
        id: resolve-versions
        uses: grafana/plugin-actions/e2e-version
        with:
          # target all minor versions of Grafana that have been released since the version that was specified as grafanaDependency in the plugin
          version-resolver-type: plugin-grafana-dependency

  playwright-tests:
    needs: setup-matrix
    strategy:
      matrix:
        GRAFANA_VERSION: ${{fromJson(needs.setup-matrix.outputs.matrix)}}
    runs-on: ubuntu-latest
    steps:
      ...
      - name: Start Grafana
        run: docker run --rm -d -p 3000:3000 --name=grafana grafana/grafana:${{ matrix.GRAFANA_VERSION }}; sleep 30
      ...
```

### version-support-policy

```yaml
name: E2E tests - Playwright
on:
  pull_request:

jobs:
  setup-matrix:
    runs-on: ubuntu-latest
    outputs:
      matrix: ${{ steps.resolve-versions.outputs.matrix }}
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      - name: Resolve Grafana E2E versions
        id: resolve-versions
        uses: grafana/plugin-actions/e2e-version
        with:
          #target all minors for the current major version of Grafana and the last minor of the previous major version of Grafana
          version-resolver-type: version-support-policy

  playwright-tests:
    needs: setup-matrix
    strategy:
      matrix:
        GRAFANA_VERSION: ${{fromJson(needs.setup-matrix.outputs.matrix)}}
    runs-on: ubuntu-latest
    steps:
      ...
      - name: Start Grafana
        run: docker run --rm -d -p 3000:3000 --name=grafana grafana/grafana:${{ matrix.GRAFANA_VERSION }}; sleep 30
      ...
```

## Development

```bash
cd e2e-versions
npm i

#before pushing to main
npm run bundle
```
