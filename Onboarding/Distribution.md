# Distribution
A distribution is a representation of your data. You can have as many distributions as
needed of a dataset. For example, one distribution in .csv, another one in .json, etc.

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
The name of the Distribution. This field needs to be unique in this spreadsheet.

*Example:*
BGV Germplasm SPARQL distribution

> **Warning** This field should be `unique`




## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) Description
A description of the Distribution.

*Example:*
The SPARQL distribution of the BGV Germplasm data


## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) Publisher
Pointer to the Organisation that published the
resource (from the Organisation sheet; a dropdown list will appear).

*Example:*
César Gómez Campo Banco de Germoplasma Vegetal de la UPM



## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) Version 
The version indicator (name or identifier) of a
resource.

*Example:*
4.11.2

## ![](https://placehold.jp/17/ea9999/000000/20x20.png?text=R) Access Rights
Information about who can access the
resource or an indication of its security status.
This should point to a URL where this
information can be found. 

In most cases, it will be "Contact the owner/curator of this resource to determine your access rights"



## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Media Type
If you have more than one media type
available for your resource and you wish to
make them all accessible, you need to add
another “Distribution”. A dropdown list will appear and let you choose from the pre-set list of media types.

*Example:*
sparql-results+json



## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Is Part Of
Refers to related resources in which this
distribution is physically or logically included (as URLs)

*Example:*
https://w3id.org/bgv-fdp/dataset/f7600b9f-cd18-4122-86c6-b6f5a75ecc03




## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Type
Whether the data can be accessed or downloaded

## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) AccessService

Pointer to the Access Service

*Example:*
http://edamontology.org/format_3790