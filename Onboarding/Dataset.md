# Dataset
This sheet describes any germplasm-related dataset.

### Legend:
- ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) This column is **Mandatory**
- ![](https://placehold.jp/17/ea9999/000000/20x20.png?text=R) This column is **HEAVILY RECOMMENDED**
- ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) This column is **OPTIONAL**


## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) License 
This should contain a URL that provides details regarding the license that is applicable to this resource.
If no suitable license can be provided, then the default license should be used:
[https://w3id.org/ejp-rd/resources/licenses/](https://w3id.org/ejp-rd/resources/licenses/). This basically says to contat the resource owner to get information about the license information.

 Examples of other licenses: 
Any subtype of [https://creativecommons.org/licenses/](https://creativecommons.org/licenses/),
e.g. [http://creativecommons.org/licenses/by-nc-nd/4.0](http://creativecommons.org/licenses/by-nc-nd/4.0).


## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) Title
The name **of the dataset**. This needs to be unique in this spreadsheet.

*Example:*
BGV June 2023

> **Warning** This field should be `unique`


## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) Description
A description of the Dataset.

*Example:*
Metadata snapshot of BGV taken in June 2023



## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) Theme
Points to an URL that specifies relevant concepts that classify the resource. They must be ontological terms, and typically, these can be looked
up using the [Ontology Lookup Service (OLS)](https://www.ebi.ac.uk/ols4/index)  or [Bioportal](https://bioportal.bioontology.org/). In the case of species names, we recommend using the [World Flora Online Taxonomy](https://www.worldfloraonline.org/search?query=)

*Example:*
https://www.worldfloraonline.org/taxon/wfo-0000481006



## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) Publisher
Pointer to the Organisation that published the
resource (from the Organisation sheet; a dropdown list will appear).

*Example:*
César Gómez Campo Banco de Germoplasma Vegetal de la UPM


## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) Contact Point
Pointer to a Contact Point (from the Contact Point sheet; a dropdown list will appear)

*Example:*
http://www.bancodegermoplasma.upm.es/


## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) PersonalData
Set to "true" if the resource onboarded to the Virtual Platform contains personal data, personal data
meaning data related to indentified or identifiable persons (as per GDPR definition), otherwise "false".


## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) Language
An ISO 639-1 two-letter code for the
languages this patient registry is provided
in. Example: en indicates that this patient
registry is available in English. The range is
an xsd:string. The ISO language codes
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
information regarding the dataset. Any URL
must start with http:// or https://.

## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Distribution

The distribution (from the distribution sheet; a dropdown list will appear) for this dataset.

*Example:*
SPARQL distribution of Administrative data

## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) VPConnection
This property is attached to every
portion of your Metadata record
that you wish the VP to explore
(e.g. Dataset X, Data Service Y, but
NOT Dataset Z). If you do not add
this tag to at least the description of
your resource, you will not be
onboarded.
The value is [https://w3id.org/ejp-rd/vocabulary#VPDiscoverable](https://w3id.org/ejp-rd/vocabulary#VPDiscoverable) (a dropdown list will appear)



## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Keyword
Keywords applicable to this Dataset

*Example:*
Papaver rhoeas


## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Logo
A link to the graphic representation
of this dataset.



## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Identifier
Identifier of this resource. It can be
a link.

*Example:*
https://w3id.org/bgv-fdp/dataset/f7600b9f-cd18-4122-86c6-b6f5a75ecc03



## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Issued
This resource publication date, in the format YYYY-MM-DDTHH:MM:SS


*Example:*
2023-11-03T14:07:46

> **Warning** This field should be in a specific format (YYYY-MM-DDTHH:MM:SS)

## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Modified
This resource last revision date, in the format YYYY-MM-DDTHH:MM:SS


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
https://fdp.bgv.cbgp.upm.es/profile/2f08228e-1789-40f8-84cd-28e3288c3604

