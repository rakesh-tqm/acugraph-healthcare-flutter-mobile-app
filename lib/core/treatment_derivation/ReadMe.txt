Treatment derivation in AcuGraph is pretty complex, and is used for a bunch of things. When a user views a graph,
they are presented with a selector to decide what kind of treatment they want to offer: Basic, Advanced, Expert
Auricular (ear), Back Shu, and Divergent. These are all separate and distinct treatment protocols, but they
all share some basic information and calculations. The Treatment Derivation library is used to support all
these treatment methods.

At its core, before ANY treatment options can be provided, this library must calculate a whole bunch of things such
as the Mean, High, Low, Split, etc for the graph, as well as the PIE score, age of the patient, effective
gender of the patient and so on... in some cases it needs to look back at the history of the patient's prior
exams to look for trends, etc. In many ways, this module is the very core of why AcuGraph is diagnostically
relevant - The practitioner uses AcuGraph to perform an exam, which is really just measuring the
galvanic skin response at 24 acupuncture points on the hands and feet - with those 24 numbers, this treatment
derivation module does ALL the heavy lifting of interpreting what those measurements MEAN, and suggesting
how to most effectively treat the imbalances that are found in the exam.

Note that Xojo and Dart treat private variables differently - Xojo had a specific toggle to make something
private, Dart requires it be _named with an underscore. I'd prefer to have the ported Dart code be as clean
as possible (though there are definitely going to be some paradigm differences) so I'm changing all the
private variable names to be in line with Dart naming conventions, and generating Dart-style accessors.
These accessors are used all over the place in the treater and in stuff that relies on the treater in AcuGraph,
so if errors crop up, look for incorrectly named/used/followed accessor paths.



TODO: EKL - Update This Note
NOTE: THIS LIBRARY IS __FAR__ FROM FINISHED.

In AcuGraph 5 (Written in Xojo) the logic which drew the graphs was intertwined with this treatment
derivation logic. For AGCS, I am going to provide a more clear separation between the 2, so a better entry point
and simpler setup can be achieved within this codebase. For now, this note exists to remind me to come
back after I've finished implementing the library to update this note with suggestions about how / when
to use treatment derivation, etc.
