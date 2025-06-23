# Archive

A digital archive of saved items like PDFs, articles, video files or anything else you want to save and present online. This was built as a personal collection of items saved from obscurity and backed up on the Internet Archive.

## Requirements

* pandoc 
* jq

pandoc is used for page conversion from markdown templates to html files. jq is used to extract and parse data from the markdown front matter of individual item pages, pulled out using a pandoc lua filter.

## To use

New items get added to the items sub-directory. 

From the archive root directory run the build.sh script. You can make it executable `chmod +x build.sh` and run it `./build.sh` after making changes to the site.

The site is built and placed in the docs subdirectory, so that one could host the site on GitHub pages for example very easily by selecting the docs source directory on GitHub Page settings. You can modify the build script for different options. 

After running the build script, to view the site locally, go to the docs folder and run a local server, such as python's simple `python3 -m http.server`, or via VS Code's Live-server or any other preferred method.

Upload the contents of the docs directory to your web host.

## Directory structure

```diagram
.
├── build.sh
├── items/
│   └── your markdown files
├── templates/
│   ├── item.html
│   ├── header.html
│   └── footer.html
├── docs/
│   └── (output generated here)
└── assets/
    └── css/
        └── main.css
```

### Gotchas

You can't have a colon : in any of the metadata fields. The site builder will complain and give a confusing error message. So substitute commas or hyphens instead of colons.
