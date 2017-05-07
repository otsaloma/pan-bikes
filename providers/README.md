Implementing a City Bike Data Provider
======================================

If your local city bike system is not supported by any of the existing
providers, you should primarily contribute to [pybikes][pybikes], the
backend used by the global [citybik.es][citybik.es] API. But, it's also
possible to add a new provider directly to Pan Bikes, instructions on
that below.

[pybikes]: https://github.com/eskerda/pybikes
[citybik.es]: https://citybik.es/

To implement a new city bike data provider, you need to write two files:
a JSON metadata file and a Python file that implements two functions
that return city bike data that your code fetches from your provider's
API and transforms into the format understood by Pan Bikes. The JSON and
Python API should be evident from the providers shipped with Pan Bikes –
you can start by copying one of those and adapting the code.

To download data you should always use `pan.http.get`,
`pan.http.get_json` etc. in order to use Pan Bikes' user-agent, default
timeout and error handling. See the providers shipped with Pan Bikes for
examples.

Use `~/.local/share/harbour-pan-bikes/providers` as a local installation
directory in which to place your files. Restart Pan Bikes, and your
provider should be loaded, its networks listed and available for use.
During development, consider keeping your files under the Pan Bikes
source tree and using the Python interpreter or a test script, e.g.

```python
>>> import pan
>>> provider = pan.Provider("citybikes")
>>> provider.list_networks()
>>> provider.list_stations("citybikes-helsinki")
```

and qmlscene (`qmlscene qml/pan-bikes.qml`) for testing. Once your
provider is ready for wider use, send a pull request on [GitHub][pull]
to have it added to the repository and shipped as part of Pan Bikes.

[pull]: https://github.com/otsaloma/pan-bikes/pulls
