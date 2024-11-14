[//]: # (TODO: Translate image for step2)
[![Static Badge](https://img.shields.io/badge/lang-en-blue?style=plastic)](../README.md)
> **Note** You can access english versions of each of the sections of this documentation by clicking on the button in the top left corner of each screen.

> **Nota** Para obtener información sobre [cómo unirte a la plataforma FLAIR-GG](https://wilkinsonlab.github.io/FLAIR-GG/SemanticModel/index.html), y [cómo funciona el proceso de transformación de los datos](https://wilkinsonlab.github.io/FLAIR-GG/TransformationPipeline/index.html), haz click en los correspondientes links.


# Cómo describir un recurso
Aquí se encuentran los pasos para describir los metadatos de un recurso que participa en la red del proyecto FLAIR-GG.

## Paso nº1
Descarga la [plantilla en formato Excel](../FLAIR-GG%20Resource%20Metadata%20Template.xlsx) o crea una copia de la [plantilla como hoja de cálculo de Google](https://docs.google.com/spreadsheets/d/1hHY6DmIrxGKTJbxrskprdvO-BiaxS8MZ/edit?usp=sharing&ouid=107877758444685576540&rtpof=true&sd=true)
> **Nota** Ambas versiones son idénticas

## Paso nº2

Rellena las diferentes hojas dentro de la hoja de cálculo según lo apropiado para tu organizacion u organizaciones y los recursos que proveen.

>**Nota** La plantilla tiene una línea con ejemplos en cada hoja, que contienen los metadatos reales del Banco de Germoplasma Vegetal César Gómez Campo para ayudar a tomar decisiones a la hora de rellenar la plantilla.

 
1. [Organisation](./Organisation.es.md) - Para añadir recursos a la Plataforma Virtual del proyecto FLAIR-GG, es necesario registar las organizaciones que los proporcionan. Para añadir una organización u organizaciones, la hoja Organisation ha de rellenarse. Para cada organización, los conjuntos de datos -datasets en inglés- (que pueden tener servicios de datos -data services en inglés- asociados) o servicios de datos (no vinculados a ningún set de datos específico) proporcionados por la organización deben ser añadidos.
   1. [Dataset](./Dataset.es.md) - Esta hoja debe rellenarse únicamente si tu organización proporciona acceso a uno o más sets de datos. Esta hoja captura los detalles de tu(s) conjunto(s) de datos. Sin embargo, un único conjunto de datos puede tener varias formas en las que se hace disponible a los potenciales usuarios. La(s) manera(s) en las que se puede acceder a un conjunto de datos se definen en la hoja de Distribución -Distribution en inglés-
      1. [Distribution](./Distribution.es.md) - Un único conjunto de datos puede estar disponible de distintas formas. P.ej. puede ser descargado, o accedido en línea.
      El [punto de contacto](./ContactPoint.es.md) para este conjunto de datos debe ser añadido si aún no se ha añadido.
   2. [Data Service](./DataService.es.md) - Si tu organización proporciona un servicio para explorar o buscar en el conjunto de datos, esta hoja debe rellenarse. El [punto de contacto](./ContactPoint.es.md) para este conjunto de datos debe ser añadido si aún no se ha añadido.
2. [Catalog](./Catalog.es.md) - Si tu organización quiere englobar múltiples conjuntos de datos o servicios de datos bajo un único título, es necesario rellenar esta hoja. El [punto de contacto](./ContactPoint.es.md) para este conjunto de datos debe ser añadido si aún no se ha añadido.


## Paso nº3
Exporta la plantilla. Recomendamos que la exportes como archivo delimitado por tabuladores (TSV), ya que es posible que las descripciones y direcciones contangan comas.


<br />
<br />


<div align="center">

<a href="">[![Static Badge](https://img.shields.io/badge/Próxima%20Hoja-Organisation-green?style=for-the-badge)](./Organisation.es.md)</a>
</div>


