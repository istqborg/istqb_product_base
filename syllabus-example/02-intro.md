# Examples of using the `\LaTeX`{=tex} template for ISTQB documents

You can write keywords and learning objectives as follows:

``` md
#### Keywords

coverage, debugging, defect, error, failure, quality, quality assurance

#### Learning Objectives for Chapter 1: {.learning-objectives}

1. Subchapter x.1 name
    1. (K1) First Learning Objective for Subchapter x.1, so it is x.1.1
    2. (K2) Second Learning Objective for Subchapter x.1, so it is x.1.2
    3. (K2) Third Learning Objective for Subchapter x.1, so it is x.1.3
2. Subchapter x.2 name
    1. (K3) First Learning Objective for Subchapter x.2, so it is x.2.1
    2. (K2) Second Learning Objective for Subchapter x.2, so it is x.2.2
3. Subchapter x.3 name
    1. (K4) First Learning Objective for Subchapter x.3, so it is x.3.1
```

This will produce the following output:

#### Keywords

coverage, debugging, defect, error, failure, quality, quality assurance

#### Learning Objectives for Chapter 1: {.learning-objectives}

1. Subchapter x.1 name
    1. (K1) First Learning Objective for Subchapter x.1, so it is x.1.1
    2. (K2) Second Learning Objective for Subchapter x.1, so it is x.1.2
    3. (K2) Third Learning Objective for Subchapter x.1, so it is x.1.3
2. Subchapter x.2 name
    1. (K3) First Learning Objective for Subchapter x.2, so it is x.2.1
    2. (K2) Second Learning Objective for Subchapter x.2, so it is x.2.2
3. Subchapter x.3 name
    1. (K4) First Learning Objective for Subchapter x.3, so it is x.3.1

Notice that the prefix FL- was automatically added to the learning objectives.
This prefix is specified in file `syllabus-example/metadata.yml` as `prefix: FL`.
