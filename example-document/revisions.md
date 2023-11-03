# Revision History {- .revision-history}
History information should be entered below in chronological order starting with most recent revision to be entered in first available line.  
The file version should follow the format vM-mm where M is the major version and mm is the minor version with a leading zero.
Date: Provide the date of the version in the following format YYYY/MM/DD  
Remarks: Provide a brief summary of the changes in that version.  
Note: Version of syllabus sent for GA approval shall include all public and non-public versions (e.g. Pre- Alpha, Alpha and Beta). These revisions must be removed prior to launch by the product team,

To write a revision history, create an unnumbered section with the class `revision-history` as follows:

```
# Revision History {- .revision-history}
```

This will produce the same output as the heading of this section.

You can list the revisions as follows:

``` md
| Version | Date | Remarks |
|---------|------|---------|
vM.mm | YYYY/MM/DD |  Maintenance release with minor updates on chapters 2, 4, 5
v4.0 | YYYY/MM/DD | General release version
v3.1.1 | YYYY/MM/DD | Copyright and logo update
v1.2.3 | YYYY/MM/DD | If remaks are longer, they can be split into more lines by using the percent sign % 
which serves as a line break.
```

This will produce the following output:

| Version | Date | Remarks |
|---------|------|---------|
vM.mm | YYYY/MM/DD |  Maintenance release with minor updates on chapters 2, 4, 5
v4.0 | YYYY/MM/DD | General release version
v3.1.1 | YYYY/MM/DD | Copyright and logo update
v1.2.3 | YYYY/MM/DD | If remaks are longer, they can be split into more lines by using the percent sign % 
which serves as a line break.