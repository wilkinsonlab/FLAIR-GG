[![Static Badge](https://img.shields.io/badge/lang-es-yellow?style=plastic)](../Es%20Documentation/DataService.es.md)
# Data Service
Data services are resources that provide access to data or analytical tools via some
interface. The interface may be machine-readable (I.e., an Application Programming
Interface – API) or via a Web page for humans to interact manually. There are different
conventions for data services on the VP Portal, depending on the “nature” of the service.
Resources that serve via a Web page, must have a landingPage property. On the
FLAIR-GG Virtual Platform, a data service that serves a Dataset must be connected to a Distribution
of that Dataset. A service not serving a dataset (e.g.,
a statistical analysis service, or an ontology lookup service) must be connected to the
top-level Catalog.

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



## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) Type 
In the context of a Data Service, use one of the children of [EDAM Operation](http://edamontology.org/operation_0004). 

In most cases, this will be http://edamontology.org/format_3790  (SPARQL)



## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) Title
The name of the Data Service. This is a
required field and needs to be unique.

*Example:*
SPARQL distribution of Administrative data


> **Warning** This field should be `unique`.



## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) Description
A description of the Data Service.

*Example:*
Administrative data distributed via a public SPARQL endpoint




## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) Personal Data
Set to "true" if the resource onboarded to
the Virtual Platform contains personal
data, personal data meaning data
related to identified or identifiable
persons (as per GDPR definition),
otherwise "false".

>

## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) Publisher
Pointer to the Organisation that published the
resource (from the Organisation sheet; a dropdown list will appear).

*Example:*
César Gómez Campo Banco de Germoplasma Vegetal de la UPM


## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) Theme
Points to an URL that specifies relevant concepts that classify the resource. They must be ontological terms, and typically, these can be looked
up using the [Ontology Lookup Service (OLS)](https://www.ebi.ac.uk/ols4/index)  or [Bioportal](https://bioportal.bioontology.org/). 

In most cases, this will be http://edamontology.org/format_3790 (SPARQL)




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




## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) Contact Point
Pointer to a Contact Point (from the Contact Point sheet; a dropdown list will appear)

*Example:*
http://www.bancodegermoplasma.upm.es/


## ![](https://placehold.jp/17/ea9999/000000/20x20.png?text=R) Access Rights
Information about who can access the
resource or an indication of its security status.
This should point to a URL where this
information can be found. 

In most cases, it will be "Contact the owner/curator of this resource to determine your access rights"


## ![](https://placehold.jp/17/ea9999/000000/20x20.png?text=R) Conforms To
If applicable, it should point to the
URL, an established standard to
which the data within the
described resource conforms (e.g.
MAGE-ML for Microarray data).

*Example:*
https://w3id.org/bgv-fdp/profile/02c649de-c579-43bb-b470-306abdc808c7


## ![](https://placehold.jp/17/ea9999/000000/20x20.png?text=R) Landing Page
The URL to the web page that serves
the data service. **This field is required
for services that do not have an API.**


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




## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Logo
A link to the graphic
representation of this resource.



## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Serves Dataset
Used to indicate which dataset
a DataService is serving data
from (from the Dataset sheet; a dropdown list will appear)

*Example:*
BGV June 2023





## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Keyword
Keywords applicable to this
data service

*Example:*
Germplasm, SPARQL



## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Identifier
Identifier of this resource. It can be
a link.

*Example:*
https://w3id.org/bgv-fdp/dataservice/8d6afe17-a1d4-4df3-b2f5-4c7310f9060d



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


