[![Static Badge](https://img.shields.io/badge/lang-en-blue?style=plastic)](../En%20Documentation/Catalog.md)
# Catalog
Describe un catálogo de conjuntos de datos y servicios de datos. Es posible que un catálogo también pueda consistir en catálogos. Para ser significativo, un catálogo debe consistir en al menos 1 conjunto de datos, servicio de datos o, de lo contrario, 1 o más catálogos.

### Leyenda:
- ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) Esta columna es **OBLIGATORIA**
- ![](https://placehold.jp/17/ea9999/000000/20x20.png?text=R) Esta columna es **RECOMENDADA**
- ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Esta columna es **OPCIONAL**

## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) License
Debe contener una URL que proporcione detalles sobre la licencia aplicable a este recurso. Si no se puede proporcionar una licencia adecuada, se debe utilizar la licencia predeterminada: [https://w3id.org/ejp-rd/resources/licenses/](https://w3id.org/ejp-rd/resources/licenses/). Básicamente, esto indica contactar al propietario del recurso para obtener información sobre la licencia.

 Ejemplos de otras licencias:
Cualquier subtipo de [https://creativecommons.org/licenses/](https://creativecommons.org/licenses/),
por ejemplo, [http://creativecommons.org/licenses/by-nc-nd/4.0](http://creativecommons.org/licenses/by-nc-nd/4.0).

## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) Title
El nombre del catálogo. Este campo debe ser único en esta hoja de cálculo.

*Ejemplo:*
Colecciones del Banco de Germoplasma

> **Advertencia** Este campo debe ser `único`

## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) Publisher
Enlace a la Organización que publicó el recurso (de la hoja de Organización; aparecerá una lista desplegable).

*Ejemplo:*
César Gómez Campo Banco de Germoplasma Vegetal de la UPM

## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) Personal Data
Establezca "true" si el recurso embarcado en la Plataforma Virtual contiene datos personales, siendo datos personales aquellos relacionados con personas identificadas o identificables (según la definición del GDPR), de lo contrario "false".

## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) Description
Una descripción del Catálogo.

*Ejemplo:*
Descripciones de las colecciones de germoplasma disponibles en el BGV

## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) Theme
Apunta a una URL que especifique conceptos relevantes que clasifiquen el recurso. Deben ser términos ontológicos y típicamente, estos pueden ser consultados utilizando el [Ontology Lookup Service (OLS)](https://www.ebi.ac.uk/ols4/index) o [Bioportal](https://bioportal.bioontology.org/). En la mayoría de los casos, será https://schema.org/catalog (Catálogo)

## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) Contact Point
Enlace a un Punto de Contacto (de la hoja de Punto de Contacto; aparecerá una lista desplegable).

*Ejemplo:*
http://www.bancodegermoplasma.upm.es/

## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) Language
Un código de dos letras ISO 639-1 para los idiomas en los que se proporciona este registro de pacientes. Ejemplo: en indica que este registro de pacientes está disponible en inglés. El rango es un xsd:string. Los códigos de idioma ISO se pueden encontrar en:
[https://id.loc.gov/vocabulary/iso639-1.html](https://id.loc.gov/vocabulary/iso639-1.html)

*Ejemplo:*
en

## ![](https://placehold.jp/17/ea9999/000000/20x20.png?text=R) Access Rights
Información sobre quién puede acceder al recurso o una indicación de su estado de seguridad. Esto debería apuntar a una URL donde se pueda encontrar esta información. En la mayoría de los casos, será "Contacte al propietario/curador de este recurso para determinar sus derechos de acceso"

## ![](https://placehold.jp/17/ea9999/000000/20x20.png?text=R) Landing Page
Esta es una URL a una página web con más información sobre el Catálogo. Cualquier URL debe comenzar con http:// o https://.

## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Dataset
Enlace al conjunto de datos(es) (de la hoja de conjunto de datos) contenido(s) dentro de este catálogo. Si hay varios conjuntos de datos contenidos, deben separarse por comas.

*Ejemplo:*
https://fdp.bgv.cbgp.upm.es/dataset/f7600b9f-cd18-4122-86c6-b6f5a75ecc03, https://fdp.bgv.cbgp.upm.es/dataset/65ffbf3d-bed1-4a9a-abf9-0116cc35b40a, https://fdp.bgv.cbgp.upm.es/dataset/03a8b103-a408-4c1d-88c0-5c4e4417f499

> **Advertencia** Si este campo contiene más de un conjunto de datos, deben separarse por comas (ver ejemplo arriba)

## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Theme Taxonomy
Apunta a una URL que especifique conceptos relevantes que clasifiquen los **contenidos del catálogo**. Deben ser términos ontológicos y típicamente, estos pueden ser consultados utilizando el [Ontology Lookup Service (OLS)](https://www.ebi.ac.uk/ols4/index) o [Bioportal](https://bioportal.bioontology.org/). En el caso de nombres de especies, recomendamos utilizar la [Taxonomía en línea de Flora Mundial](https://www.worldfloraonline.org/search?query=)

*Ejemplo:*
https://www.worldfloraonline.org/taxon/wfo-0000659225, https://www.worldfloraonline.org/taxon/wfo-0000729203, https://www.worldfloraonline.org/taxon/wfo-0000729205, https://www.worldfloraonline.org/taxon/wfo-4000000074

> **Advertencia** Si este campo contiene más de una taxonomía de tema, deben separarse por comas (ver ejemplo arriba)

## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Homepage 
Esta es una URL a una página web con más información sobre el catálogo. Cualquier URL debe comenzar con http:// o https://.

## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) VPConnection
Esta propiedad está adjunta a cada parte de su registro de metadatos que desee que el VP explore (por ejemplo, Conjunto de datos X, Servicio de datos Y, pero NO Conjunto de datos Z). Si no agrega esta etiqueta al menos a la descripción de su recurso, no será embarcado. El valor es [https://w3id.org/ejp-rd/vocabulary#VPDiscoverable](https://w3id.org/ejp-rd/vocabulary#VPDiscoverable) (aparecerá una lista desplegable)

## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Keyword
Palabras clave aplicables a este catálogo

*Ejemplo:*
Germoplasma



## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Logo
Un enlace a la representación gráfica
de este recurso.




## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Distribution
Utilice esta propiedad para señalar la distribución de este
catálogo cuando esté disponible (de la hoja de Distribución; aparecerá una lista desplegable)

*Ejemplo:*
Distribución SPARQL de datos administrativos




## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Identifier
Identificador de este recurso. Puede ser
un enlace.

*Ejemplo:*
https://w3id.org/bgv-fdp/catalog/3e699f66-6b8a-4c6a-9d06-d8685718cc33


## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Issued
Fecha de publicación de este recurso, en el formato AAAA-MM-DDTHH:MM:SS


*Ejemplo:*
2023-11-03T14:07:46

> **Advertencia** Este campo debe estar en un formato específico (AAAA-MM-DDTHH:MM:SS)


## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Modified
Fecha de la última revisión de este recurso, en el formato AAAA-MM-DDTHH:MM:SS


*Ejemplo:*
2023-11-03T14:07:46

> **Advertencia** Este campo debe estar en un formato específico (AAAA-MM-DDTHH:MM:SS)



## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Version
El indicador de versión (nombre o
identificador) de un recurso.

*Ejemplo:*
4.11.2

## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Conforms To
Si corresponde, debe apuntar a la
URL, un estándar establecido al que
los datos dentro del
recurso descrito se conforman (por
ejemplo, MAGE-ML para datos de microarrays).

*Ejemplo:*
https://w3id.org/bgv-fdp/profile/a0949e72-4466-4d53-8900-9436d1049a4b

