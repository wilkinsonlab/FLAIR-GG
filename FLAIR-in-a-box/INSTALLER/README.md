# FLAIR-in-a-Box Quick Start!
---

FLAIR-in-a-box (Fiab) implements a workflow that utilizes CSV and YARRRML as templates to define the RDF shape and its transformation.

The only requirement you have to worry about is the CSV template that contains germplasm, location, or administrative data that follows the FLAIR-GG semantic models. Check the documentation at this [link](https://github.com/wilkinsonlab/FLAIR-GG/tree/main/SemanticModel/CSV) to understand how to creating and populating your CSV template.

It is best to follow conventions for naming the CSV.  Administrative data should be called `administrative.csv`, location data should be called `location.csv`, and germplasm data should be called `germplasm.csv`, put this CSV file into the `XXX-ready-to-go/data` folder (XXX is the prefix you selected during the install). You can find [exemplar data](https://github.com/wilkinsonlab/FLAIR-GG/tree/main/SemanticModel/CSV) in case you have any uncertainty with your own template.

You can now trigger the transformation by calling a web address that includes the primary name of your CSV file (e.g. 'administrative' ), for example: `http://localhost:4567/administrative`  (the port 4567 should be changed to the port that you selected for RDF transformation trigger, during installation). After a few seconds, your output data will appear in the `XXXX-ready-to-go/data/triples` folder, and will have already been automatically uploaded into GraphDB's database.
