# yarrrml-rml-mapper-flair (LEGACY)

> **Legacy component.** This is the YARRRML/RML mapper (`yarrrml-rdfizer` container, images
> `markw/yarrrml-rml-ejp`) used by the original GraphDB-based FLAIR-in-a-Box together with the
> [`flair-box-daemon`](../FLAIR-box-daemon/). The source stays here so that image can still be rebuilt and
> patched for the existing installations. **New installations use the Sextans Suite's `yarrrml-rml` mapper**
> (installed by Sextans Fix; see [FLAIR-in-a-Box](../FLAIR-in-a-box/)).
>
> **Do not deploy it for anything new.** It predates the Sextans mapper's shell-injection fix: `t.rb` builds the
> `map.sh` command line from the requested URL path. In the legacy stack the mapper's port is not published, so
> only the daemon can reach it. Keep it that way. Retirement is tracked in [TODO.md](../TODO.md).

## Usage (legacy stack)

```yaml
services:
  yarrml-rdfizer:
    image: markw/yarrrml-rml-ejp:0.1.1
    environment:
      - SERIALIZATION=nquads
    volumes:
      - ./data:/mnt/data
```

Put your data and your YARRRML files in the `./data` folder, following these naming conventions:

```text
CARE.csv
CARE_yarrrml.yaml
```

In your YAML file, the `access` clause should point to `/mnt/data` (for example `/mnt/data/CARE.csv`):

```yaml
sources:
  policy:
    access: /mnt/data/CARE.csv
    referenceFormulation: csv
    iterator: "$"
```
