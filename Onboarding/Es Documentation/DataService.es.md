[![Static Badge](https://img.shields.io/badge/lang-en-blue?style=plastic)](../En%20Documentation/DataService.md)
# Data Service
Los servicios de datos son recursos que proporcionan acceso a datos o herramientas analíticas a través de alguna
interfaz. La interfaz puede ser legible por máquina (es decir, una Interfaz de Programación de Aplicaciones - API) o a través de una página web para que los humanos interactúen manualmente. Existen diferentes convenciones para los servicios de datos en el Portal VP, dependiendo de la "naturaleza" del servicio. Los recursos que se sirven a través de una página web deben tener una propiedad landingPage. En la Plataforma Virtual FLAIR-GG, un servicio de datos que sirve a un Conjunto de Datos debe estar conectado a una Distribución de ese Conjunto de Datos. Un servicio que no sirve a un conjunto de datos (por ejemplo,
un servicio de análisis estadístico o un servicio de búsqueda de ontologías) debe estar conectado al
catálogo de nivel superior.

### Leyenda:
- ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) Esta columna es **OBLIGATORIA**
- ![](https://placehold.jp/17/ea9999/000000/20x20.png?text=R) Esta columna es **RECOMENDADA**
- ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Esta columna es **OPCIONAL**

## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) License
Esto debería contener una URL que proporcione detalles sobre la licencia que es aplicable a este recurso.
Si no se puede proporcionar una licencia adecuada, entonces se debe usar la licencia predeterminada:
[https://w3id.org/ejp-rd/resources/licenses/](https://w3id.org/ejp-rd/resources/licenses/). Básicamente dice que se debe contactar al propietario del recurso para obtener información sobre la licencia.

 Ejemplos de otras licencias:
Cualquier subtipo de [https://creativecommons.org/licenses/](https://creativecommons.org/licenses/),
por ejemplo, [http://creativecommons.org/licenses/by-nc-nd/4.0](http://creativecommons.org/licenses/by-nc-nd/4.0).

## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) Type 
En el contexto de un Servicio de Datos, use uno de los hijos de [Operación EDAM](http://edamontology.org/operation_0004).

En la mayoría de los casos, esto será http://edamontology.org/format_3790 (SPARQL)

## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) Title
El nombre del Servicio de Datos. Este es un
campo requerido y debe ser único.

*Ejemplo:*
Distribución SPARQL de datos administrativos

> **Advertencia** Este campo debe ser `único`.

## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) Description
Una descripción del Servicio de Datos.

*Ejemplo:*
Datos administrativos distribuidos a través de un punto final SPARQL público

## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) Personal Data
Establecido en "verdadero" si el recurso embarcado en
la Plataforma Virtual contiene datos personales,
datos personales significando datos
relacionados con personas identificadas o identificables
(según la definición del GDPR),
de lo contrario "falso".

## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) Publisher
Puntero a la Organización que publicó el
recurso (desde la hoja de Organización; aparecerá una lista desplegable).

*Ejemplo:*
César Gómez Campo Banco de Germoplasma Vegetal de la UPM

## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) Theme
Apunta a una URL que especifica conceptos relevantes que clasifican el recurso. Deben ser términos ontológicos, y típicamente, estos se pueden buscar
usando el [Servicio de Búsqueda de Ontología (OLS)](https://www.ebi.ac.uk/ols4/index) o [Bioportal](https://bioportal.bioontology.org/).

En la mayoría de los casos, esto será http://edamontology.org/format_3790 (SPARQL)

## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) Language
Un código ISO 639-1 de dos letras para los
idiomas en los que se proporciona este registro de pacientes
en. Ejemplo: en indica que este registro de pacientes
está disponible en inglés. El rango es
un xsd:string. Los códigos de idioma ISO
se pueden encontrar en:
[https://id.loc.gov/vocabulary/iso639-1.html](https://id.loc.gov/vocabulary/iso639-1.html)

*Ejemplo:*
en

## ![](https://placehold.jp/17/ff0000/000000/20x20.png?text=M) Contact Point
Puntero a un Punto de Contacto (de la hoja de Punto de Contacto; aparecerá una lista desplegable)

*Ejemplo:*
http://www.bancodegermoplasma.upm.es/

## ![](https://placehold.jp/17/ea9999/000000/20x20.png?text=R) Access Rights
Información sobre quién puede acceder al
recurso o una indicación de su estado de seguridad.
Esto debería apuntar a una URL donde este
información se puede encontrar.

En la mayoría de los casos, será "Póngase en contacto con el propietario/curador de este recurso para determinar sus derechos de acceso".

## ![](https://placehold.jp/17/ea9999/000000/20x20.png?text=R) Conforms To
Si corresponde, debe apuntar a la
URL, un estándar establecido al que
los datos dentro del
recurso descrito se conforman (por ejemplo,
MAGE-ML para datos de microarrays).

*Ejemplo:*
https://w3id.org/bgv-fdp/profile/02c649de-c579-43bb-b470-306abdc808c7

## ![](https://placehold.jp/17/ea9999/000000/20x20.png?text=R) Landing Page
La URL de la página web que sirve
el servicio de datos. **Este campo es requerido
para servicios que no tienen una API.**

## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) VPConnection
Esta propiedad está adjunta a cada
porción de su registro de metadatos
que desea que el VP explore
(por ejemplo, Conjunto de Datos X, Servicio de Datos Y, pero
NO Conjunto de Datos Z). Si no agrega
esta etiqueta al menos a la descripción de
su recurso, no será
embarcado.
El valor es [https://w3id.org/ejp-rd/vocabulary#VPDiscoverable](https://w3id.org/ejp-rd/vocabulary#VPDiscoverable) (aparecerá una lista desplegable)

## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Logo
Un enlace a la representación gráfica
de este recurso.

## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Serves Dataset
Se utiliza para indicar qué conjunto de datos
un Servicio de Datos está sirviendo datos
(de la hoja de Conjunto de Datos; aparecerá una lista desplegable)

*Ejemplo:*
BGV June 2023

## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Keyword
Palabras clave aplicables a este
servicio de datos

*Ejemplo:*
Germoplasma, SPARQL

## ![](https://placehold.jp/17/ffffff/000000/20x20.png?text=O) Identifier
Identificador de este recurso. Puede ser
un enlace.

*Ejemplo:*
https://w3id.org/bgv-fdp/dataservice/8d6afe17-a1d4-4df3-b2f5-4c7310f9060d

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
