[![Static Badge](https://img.shields.io/badge/lang-es-yellow?style=plastic)](../Es%20Documentation/Catalog.es.md)
# Catalog
Describes a catalog of datasets and data services. To be meaningful a catalog must consist of at least 1 dataset or data service.
### Legend:
- ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) This column is **MANDATORY**
- ![](https://placehold.jp/17/ea9999/000000/20x20.png?text=R) This column is **RECOMMENDED**
- ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) This column is **OPTIONAL**

## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) License
This should contain a URL that provides details regarding the license that is applicable to this resource.
If no suitable license can be provided, then the default license should be used:
[https://w3id.org/ejp-rd/resources/licenses/](https://w3id.org/ejp-rd/resources/licenses/). This basically says to contat the resource owner to get information about the license information.

 Examples of other licenses: 
Any subtype of [https://creativecommons.org/licenses/](https://creativecommons.org/licenses/),
e.g. [http://creativecommons.org/licenses/by-nc-nd/4.0](http://creativecommons.org/licenses/by-nc-nd/4.0).



## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) Title
The name of the catalog. This field needs to be unique in this spreadsheet.

*Example:*
Germplasm Bank Collections

> **Warning** This field should be `unique`

## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) Publisher
Pointer to the Organisation that published the
resource (from the Organisation sheet; a dropdown list will appear, allowing you to select from pre-established options).

*Example:*
César Gómez Campo Banco de Germoplasma Vegetal de la UPM


## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) Personal Data
Set to "true" if this resource contains personal
data, personal data meaning data
related to identified or identifiable
persons (as per GDPR definition),
otherwise "false".


## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) Description
A description of the Catalog.

*Example:*
Descriptions of the collections of germplasm available at the BGV


## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) Theme
Points to an URL that specifies relevant concepts that classify the resource. They must be ontological terms, and typically, these can be looked
up using the [Ontology Lookup Service (OLS)](https://www.ebi.ac.uk/ols4/index)  or [Bioportal](https://bioportal.bioontology.org/).

In most cases, this will be https://schema.org/catalog (Catalog)



## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) Contact Point
Pointer to a Contact Point (from the Contact Point sheet; a dropdown list will appear, allowing you to select from pre-established options)

*Example:*
http://www.bancodegermoplasma.upm.es/


## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) Language
An ISO 639-1 two-letter code for the
languages this patient registry is provided
in. The ISO language codes
can be found at:
[https://id.loc.gov/vocabulary/iso639-1.html](https://id.loc.gov/vocabulary/iso639-1.html)

*Example:*
en




## ![](https://placehold.jp/17/ea9999/000000/20x20.png?text=R) Access Rights
Information about who can access the
resource or an indication of its security status.
This should point to a URL where this
information can be found. 

In most cases, it will be "Contact the owner/curator of this resource to determine your access rights"



## ![](https://placehold.jp/17/ea9999/000000/20x20.png?text=R) Landing Page
This a URL to a web page with more
information regarding the Catalog. Any URL
must start with http:// or https://.



## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Dataset
Pointer to the dataset(s) (from the dataset sheet) contained within this catalog. If multiple datasets are contained within, they have to be separated by commas.

*Example:*
https://fdp.bgv.cbgp.upm.es/dataset/f7600b9f-cd18-4122-86c6-b6f5a75ecc03, https://fdp.bgv.cbgp.upm.es/dataset/65ffbf3d-bed1-4a9a-abf9-0116cc35b40a, https://fdp.bgv.cbgp.upm.es/dataset/03a8b103-a408-4c1d-88c0-5c4e4417f499

> **Warning** If this field contains more than one dataset, they must be separated by commas (see example above)


## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Theme Taxonomy
Points to an URL that specifies relevant concepts that classify the **contents of the catalog** (they are basically Keywords for computers). The best concepts to include here are what you think make your resource unique, what the users might find most interesting about your resource. They must be ontological terms, and typically, these can be looked up using the [Ontology Lookup Service (OLS)](https://www.ebi.ac.uk/ols4/index)  or [Bioportal](https://bioportal.bioontology.org/). In the case of species names, we recommend using the [World Flora Online Taxonomy](https://www.worldfloraonline.org/search?query=).

*Example:*
https://www.worldfloraonline.org/taxon/wfo-0000659225, https://www.worldfloraonline.org/taxon/wfo-0000729203, https://www.worldfloraonline.org/taxon/wfo-0000729205, https://www.worldfloraonline.org/taxon/wfo-4000000074

> **Warning** If this field contains more than one dataset, they must be separated by commas (see example above)

## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Homepage 
This a URL to a web page with more
information regarding the catalog. Any URL
must start with http:// or https://.



## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) VPConnection
This property is attached to every
portion of your Metadata record
that you wish the VP to explore
(e.g. Dataset X, Data Service Y, but
NOT Dataset Z). If you do not add
this tag to at least the description of
your resource, you will not be
onboarded to the virtual platform.
The value is [https://w3id.org/ejp-rd/vocabulary#VPDiscoverable](https://w3id.org/ejp-rd/vocabulary#VPDiscoverable) (a dropdown list will appear, allowing you to select from pre-established options)


## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Keyword
Keywords applicable to this catalog.  The best concepts to include here are what you think make your resource unique, what the users might find most interesting about your resource.


*Example:*
Germplasm



## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Logo
A link to the graphic representation
of this resource.




## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Distribution
Use this property to point to the distribution of this
catalog when a distribution is available (from the Distribution sheet; a dropdown list will appear, allowing you to select from pre-established options)

*Example:*
SPARQL distribution of Administrative data




## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Identifier
Identifier of this resource. It can be
a link.

*Example:*
https://w3id.org/bgv-fdp/catalog/3e699f66-6b8a-4c6a-9d06-d8685718cc33


## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Issued
This resource's publication date, in the format YYYY-MM-DDTHH:MM:SS


*Example:*
2023-11-03T14:07:46

> **Warning** This field should be in a specific format (YYYY-MM-DDTHH:MM:SS)


## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Modified
This resource's last revision date, in the format YYYY-MM-DDTHH:MM:SS


*Example:*
2023-11-03T14:07:46

> **Warning** This field should be in a specific format (YYYY-MM-DDTHH:MM:SS)



## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Version
The version indicator (name or
identifier) of a resource.

*Example:*
4.11.2

## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Conforms To
If applicable, it should point to the
URL, an established standard to
which the data within the
described resource conforms (e.g.
MAGE-ML for Microarray data).

*Example:*
https://w3id.org/bgv-fdp/profile/a0949e72-4466-4d53-8900-9436d1049a4b


<br />
<br />

<div align="center">

<a href="">[![Static Badge](https://img.shields.io/badge/Previous%20Sheet-Distribution-yellow?style=for-the-badge)](./Distribution.md)</a>
<a href="">[![Static Badge](https://img.shields.io/badge/Home-README-blue?style=for-the-badge)](../README.md)</a>
<a href="">[![Static Badge](https://img.shields.io/badge/Next%20Sheet-Dataservice-green?style=for-the-badge)](./DataService.md)</a>

</div>
