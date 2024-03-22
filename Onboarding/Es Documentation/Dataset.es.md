[![Static Badge](https://img.shields.io/badge/lang-en-blue?style=plastic)](../En%20Documentation/Dataset.md)
# Dataset
Esta hoja describe cualquier conjunto de datos relacionado con el germoplasma.

### Leyenda:
- ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=I) Esta columna es **IMPRESCINDIBLE**
- ![](https://placehold.jp/17/ea9999/000000/20x20.png?text=R) Esta columna es **RECOMENDADA**
- ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Esta columna es **OPCIONAL**


## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=I) License  
Esto debería contener una URL que proporcione detalles sobre la licencia que es aplicable a este recurso.
Si no se puede proporcionar una licencia adecuada, entonces debería usarse la licencia por defecto:
[https://w3id.org/ejp-rd/resources/licenses/](https://w3id.org/ejp-rd/resources/licenses/). Básicamente, esto dice que se debe contactar al propietario del recurso para obtener información sobre la licencia.

 Ejemplos de otras licencias: 
Cualquier subtipo de [https://creativecommons.org/licenses/](https://creativecommons.org/licenses/),
por ejemplo, [http://creativecommons.org/licenses/by-nc-nd/4.0](http://creativecommons.org/licenses/by-nc-nd/4.0).


## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=I) Title
El nombre **del conjunto de datos**. Este debe ser único en esta hoja de cálculo.

*Ejemplo:*
BGV junio 2023

> **Advertencia** Este campo debe ser `único`


## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=I) Description
Una descripción del conjunto de datos.

*Ejemplo:*
Instantánea de metadatos de BGV tomada en junio de 2023



## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=I) Theme
Indica una URL que especifique conceptos relevantes que clasifiquen el recurso (son básicamente palabras clave para ordenadores). Los mejores conceptos para añadir aquí son aquellos que describan lo que hacen tu recurso único, en lo que los usuarios podrían estar interesados sobre tu recurso que lo diferencie de los demás. Deben ser términos ontológicos, y típicamente, estos pueden buscarse
utilizando el [Ontology Lookup Service (OLS)](https://www.ebi.ac.uk/ols4/index)  o [Bioportal](https://bioportal.bioontology.org/). En el caso de los nombres de especies, recomendamos utilizar la [Taxonomía en Línea de la Flora Mundial](https://www.worldfloraonline.org/search?query=)

*Ejemplo:*
https://www.worldfloraonline.org/taxon/wfo-0000481006



## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=I) Publisher
Indica la Organización que publicó el recurso (desde la hoja Organisation; aparecerá una lista desplegable, en la que podrá seleccionar de una lista de valores preestablecidos).

*Ejemplo:*
César Gómez Campo Banco de Germoplasma Vegetal de la UPM


## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=I) Contact Point
Indica un Punto de contacto (desde la hoja Contact point; aparecerá una lista desplegable, en la que podrá seleccionar de una lista de valores preestablecidos)

*Ejemplo:*
http://www.bancodegermoplasma.upm.es/


## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=I) PersonalData
Establezca "true" si este recurso contiene datos personales, siendo datos personales aquellos relacionados con personas identificadas o identificables (según la definición del GDPR), de lo contrario "false".

## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=I) Language
Un código de dos letras ISO 639-1 para los idiomas en los que se proporciona este recurso de germoplasma.  Los códigos de idioma ISO se pueden encontrar en:
[https://id.loc.gov/vocabulary/iso639-1.html](https://id.loc.gov/vocabulary/iso639-1.html)

*Ejemplo:*
en





## ![](https://placehold.jp/17/ea9999/000000/20x20.png?text=R) Access Rights
Información sobre quién puede acceder al recurso o una indicación de su estado de seguridad.
Esto debería apuntar a una URL donde se pueda encontrar esta información. 

En la mayoría de los casos, será "Contactar al propietario/curador de este recurso para determinar sus derechos de acceso"


## ![](https://placehold.jp/17/ea9999/000000/20x20.png?text=R) Landing Page
Esta es una URL a una página web con más
información sobre el conjunto de datos. Cualquier URL
debe comenzar con http:// o https://.

*Ejemplo:*
https://fdb.bgv.cbgp.upm.es/

## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Distribution

Indica la distribución (desde la hoja Distribution; aparecerá una lista desplegable, en la que podrá seleccionar de una lista de valores preestablecidos) de este conjunto de datos.

*Ejemplo:*
Distribución SPARQL de BGV Germoplasma


## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) VPConnection
Esta propiedad está adjunta a cada
parte de su registro de metadatos
que desee que explore el VP
(por ejemplo, Conjunto de datos X, Servicio de datos Y, pero
NO Conjunto de datos Z). Si no agrega
esta etiqueta al menos a la descripción de
su recurso, no será embarcado a la plataforma virtual
El valor es [https://w3id.org/ejp-rd/vocabulary#VPDiscoverable](https://w3id.org/ejp-rd/vocabulary#VPDiscoverable) (aparecerá una lista desplegable, en la que podrá seleccionar de una lista de valores preestablecidos)



## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Keyword
Palabras clave aplicables a este Conjunto de datos. Las mejores palabras claves para añadir aquí son aquellos que describan lo que hacen tu recurso único, en lo que los usuarios podrían estar interesados sobre tu recurso que lo diferencie de los demás.


*Ejemplo:*
Papaver rhoeas


## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Logo
Un enlace a la representación gráfica
de este conjunto de datos.



## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Identifier
Identificador de este recurso. Puede ser
un enlace.

*Ejemplo:*
https://w3id.org/bgv-fdp/dataset/65ffbf3d-bed1-4a9a-abf9-0116cc35b40a



## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Issued
La fecha de publicación de este recurso, en el formato AAAA-MM-DDTHH:MM:SS


*Ejemplo:*
2023-11-03T14:07:46

> **Advertencia** Este campo debe estar en un formato específico (AAAA-MM-DDTHH:MM:SS)

## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Modified
La fecha de la última revisión de este recurso, en el formato AAAA-MM-DDTHH:MM:SS


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
URL de un estándar establecido al que
los datos dentro del
recurso descrito se conforman (por
ejemplo, MAGE-ML para datos de microarrays).

*Ejemplo:*
https://fdp.bgv.cbgp.upm.es/profile/2f08228e-1789-40f8-84cd-28e3288c3604


<br />
<br />

<div align="center">

<a href="">[![Static Badge](https://img.shields.io/badge/Hoja%20Anterior-ContactPoint-yellow?style=for-the-badge)](./ContactPoint.es.md)</a>
<a href="">[![Static Badge](https://img.shields.io/badge/Página%20Pricipal-README-blue?style=for-the-badge)](./README.es.md)</a>
<a href="">[![Static Badge](https://img.shields.io/badge/Próxima%20Hoja-Distribution-green?style=for-the-badge)](./Distribution.es.md)</a>

</div>
