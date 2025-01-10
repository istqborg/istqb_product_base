# Initial setup for GitHub, Git and VS Code

This guide will get you up to speed with setting up everything you need for successful usage of this solution.

## Dictionary of basic terms

| Term | Description |
| :--- | ----------- |
| GitHub | A web-based platform for hosting and managing Git repositories. It's a place storing all your code, collaborate with others, and contributing to the repositories. |
| Git | State-of-the-art Version Control System that tracks changes in files/code over time. It is a toll connecting you machine to GitHub. |
| VS Code | A free and most popular code/files editor developed. It's highly customizable, supports many programming languages, and offers many extensions. |
| Markdown | A lightweight markup language that uses plain text formatting syntax. It's a markup language to be used for all ISTQB documents content. |
| YAML |  A human-readable data serialization language often used configuration files. It's a language for all configurations related for ISTQB documents. |
| Repository | A place to store all the files, folders, and history of a project. Each ISTQB product is stored in separate repository. |
| Branch | A parallel version of a repository that allows you to work on new features or bug fixes in isolation without affecting the main codebase. |
| Main Branch | The default branch in a repository, often considered the "production" or "stable" version of the code. |
| Git Tag | A marker or label that you can attach to a specific commit in your Git history. It's like a bookmark, allowing you to easily reference a particular point in time.  |
| GitHub Release | A snapshot of your project at a specific point in time. It often corresponds to a Git Tag and can include artifacts as code or generated documents. | 
| Pull Request | A request to merge changes from one branch into another. It allows for code review and collaboration before changes are integrated into the main codebase. |
| Pipeline | A set of automated processes that build, test, and deploy code changes. It helps streamline the software development workflow. |
| Pipeline Artifacts | Files generated during a pipeline execution, such as compiled code, test results, or deployment packages. |

## Basic rules

* Use **Kebab Case** and lowercase characters with no accents for naming **files**. E.g. `file-name.md`
* Use **Kebab Case** and lowercase characters with no accents for naming **branches**. E.g. `chapter-4-alpha-comments`
* Use short but descriptive messages for your commits. E.g. `LOs 3.2.1 rewritten based on Alpha comments`

## Accounts and machine setup

Before you start using the solution, you need to get few things set up.   
If you are primarily a reviewer or occasional contributor, you are fine with just GitHub in Cloud.   
If you are an author, regular contributor or project leader, you would most likely want to have Git and VS Code set up on your machine.

### Create GitHub Account

GitHub is a code storage and management cloud tool. All code for the solution and content of the syllabi is stored there. 

First you need to get access:

1. Create an account at https://github.com/. It's free.
2. Define your full name in Your profile > Edit profile. It's necessary to recognize you among other users.
3. Share your GitHub username (not full name, nor email) with polan@castb.org to be added to ISTQB organization and get visibility into our repositories.

Once you can access https://github.com/istqborg/, you are good to go.


If you need some help with GitHub, check https://docs.github.com/en, which is a comprehensive documentation for all types of users.

### Install Git

Git is the main tool allowing us to version control the code and other files. It runs on your machine and is a main connection to GitHub.

To set up Git on your machine:

1. Download Git from https://git-scm.com/downloads
2. Install Git by clicking Next all the way to the end.  
You can change some settings if you know what are you doing.

To verify the installation, just type `git` into command line/terminal and see the output of git help.

Additionally, you need to set your name and email to Git, so you are identified correctly on GitHub. Run following two commands in command line/terminal:

* `git config --global user.name "<your_full_name>"`
* `git config --global user.email "<email_used_to_register_to_GitHub>"`

### Install VS Code

VS Code is one of the most versatile code editor with many extensions for your machine. You do not have to use it, but it's great.

To set up VS Code on your machine:
1. Download VS Code from https://code.visualstudio.com/download
2. Install VS Code
3. Install extensions to your VS Code.  
Click *Cubes* icon in the left menu panel to open Extensions menu.
4. Best extensions for our purpose are  
[Markdown Editor by zaaack](https://marketplace.visualstudio.com/items?itemName=zaaack.markdown-editor) for WYSIWIG editor of Markdown files
[LTeX – LanguageTool grammar/spell checking by Julian Valentin](https://marketplace.visualstudio.com/items?itemName=valentjn.vscode-ltex) for grammar checks
[Julian Valentin by RedHat](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml) for YAML files syntax  
There are many more extensions, you can use many others as they suit you.

If you need some help with VS Code, I would start with https://code.visualstudio.com/docs.

### Cloning your first repository

Navigate to your VS Code and Click *Branches* icon in the left menu panel to open Source Control menu.  
Here you can authenticate to GitHub and clone repositories as you need.

See https://code.visualstudio.com/docs/sourcecontrol/intro-to-git for more details.

## Git operations

This is the list of Git operations you will be using the most.

| Git action | Description |
| :--------- | ----------- |
| Git Clone | Creates a copy of a remote repository on your local machine. It downloads all the files, branches, and commit history. |
| Git Pull  | Updates your local repository with the latest changes from the remote repository. It fetches new commits and merges them into your current branch. |
| Git Push  | Uploads your local commits to the remote repository. This shares your changes with others and updates the remote branch. |
| Git Stage | Adds changes to the staging area. This prepares the selected files for inclusion in the next commit. Think of it as adding items to your shopping cart before checking out. |
| Git Unstage | Removes changes from the staging area. This removes files from the "shopping cart" so they won't be included in the next commit. |
| Git Commit | Creates a snapshot of your changes, adding a new entry to the project's history. It's like saving your progress with a message describing the changes. |
| Git Merge | Combines changes from one branch into another. This integrates new features or bug fixes into the main codebase. |

## VS Code editor tips and tricks

Consider using these features while using VS Code

* settings
  * Files: Auto Save = onFocusChange
  * Git: AutoFetch = True
* search files
* search within a file
* search and replace
* search with options (match case, match whole word, user regular expression)
* global search and replace
* multiline select

## Useful links

* GitHub Help: https://docs.github.com/en
* VS Code Help: https://code.visualstudio.com/docs
* VS Code Extensions: https://marketplace.visualstudio.com/vscode
* VS Code Shortcuts for Win: https://code.visualstudio.com/shortcuts/keyboard-shortcuts-windows.pdf
* VS Code Shortcuts for Mac: https://code.visualstudio.com/shortcuts/keyboard-shortcuts-macos.pdf
* Visualizing Git actions: https://git-school.github.io/visualizing-git/#free
* Learning Git Branching: https://learngitbranching.js.org/
* Markdown Cheatsheet: https://github.com/adam-p/markdown-here/wiki/markdown-cheatsheet