# Troubleshooting {#troubleshooting}

Many pipeline failures are caused by justa few issues. This section describes the debugging process of a failed pipeline.

First of all, to see the pipeline statu:
1. Go to your repository
2. Open Actions tab
3. Open detail of your pipeline run
4. Find out what job is failing
5. See detailed logs of failed job
6. Seach for commonly known error messages using native GitHub log search on top right corner

## Validate YAML documents

YAML formatting is strict, and all errors in this job are related to it. Search for `yaml.scanner.ScannerError` to see what went wrong. Example of the log:

```
yaml.scanner.ScannerError: mapping values are not allowed in this context
  in "/__w/istqb-ctal-ta/syllabus/metadata.yml", line 3, column 7
```
To resolve these issues:
1. Navigate to affected file (`syllabus/metadata.yml` line 3, position 7 in this case)
2. Resolve the formatting issues which could be cause by several things. The most common are:
  * wrong indents - fix by adding 2 spaces per indent level
  * using colon `:` or hashtag `#` in the text - fix by adding the text in quotes `"` or `'`
3. Use online YAML linters like [yamllint.com](https://www.yamllint.com/) to test your YAML file

## Produce PDF documents

### Undefined references and citations

The most common failure is one related to references. Search for `Undefined refs and citations` to see what went wrong. Example of the log:

```
	Latexmk: ====Undefined refs and citations with line #s in .tex file:
	  Reference `section:analyze-sut-to-determine-the-appropriate-tas'
	    on page 21 undefined on input line 37
	  Reference `section:apply-layering-of-taf'
	    on page 22 undefined on input line 38
	  Reference `section:apply-design-principles-and-design-patterns-in-ta'
	    on page 24 undefined on input line 38
	  Reference `section:apply-different-approaches-for-automating-tcs'
	    on page 47 undefined on input line 43
	  Reference `section:apply-layering-of-taf'
	    on page 48 undefined on input line 43
	  Reference `section:explain-which-factors-support-and-affect-tas-maintainability'
	    on page 50 undefined on input line 43
	```

Example of the log:

1. Make sure your section identifier `{#apply-layering-of-taf}` is existent within your MD files. See <#section:section-references> for more details.
2. Make sure you are using the reference in text like `<#section:#apply-layering-of-taf>` correctly. Typos are common here. See <#section:section-references> for more details.
3. Make sure, all Markdown files you are referencing to are part of the `.tex` file, so they are included in a final rendered file. See <#section:architecture-of-the-solution> for mode details.


## Invalid references to files in `syllabus.tex` file

Every MD files you want to include in your document have to be added to TEX file. If the file referenced in the TEX file is not existent (wrong path, wrong name of the file, missing extension, etc.) the pipeline job will fail. Example of the log:

```
	! Package markdown Error: Markdown file
	(markdown)                syllabus/01-tasks-in-**test**-process.md
	(markdown)                does not exist
```

These errors can also seem in *Produce DOCX documents* pipeline job. But the output here will show only the name of the first file missing. Example of the log:

```
	FileNotFoundError: [Errno 2] No such file or directory:
	  '/__w/istqb-ctal-ta/istqb-ctal-ta/syllabus/01-tasks-in-**test**-process.md'
```

To resolve these issues:

1. Open TEX file of your document (e.g. `syllabus.tex`) and check that all paths are valid
   ```tex
   % Document Text
   \markdownInput{syllabus-en/acknowledgments.md}
   \markdownInput{syllabus-en/00-introduction.md}
   \markdownInput{syllabus-en/01-tasks-in-**the-test**-process.md}
   \markdownInput{syllabus-en/02-tasks-in-the-risk-based-testing.md}
   \markdownInput{syllabus-en/03-test-analysis-and-design.md}
   \markdownInput{syllabus-en/04-testing-software-quality-characteristics.md}
   \markdownInput{syllabus-en/05-software-defect-prevention.md}
   ```
1. Update paths to all MD files listed in error log.
1. Commit changes to TEX file


