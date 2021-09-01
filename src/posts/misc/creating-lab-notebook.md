---
date: 2021-08-31
tags:
  - posts
  - science-communication
eleventyNavigation:
  key: Creating an online lab notebook.
  parent: Scientific Computing
layout: layouts/post.njk
---

1. In order to duplicate what I have here, just click the "remix on glitch" button in the lower righthand corner. 
1. Set up a glitch account.
1. Posts are listed under `src/posts`. When creating a new post, copy and paste a header like
```
---
title: Creating an online web notebook.
date: 2021-08-31
tags:
  - posts
  - some
  - other
  - tags
  - here
layout: layouts/post.njk
---

```
into the top of the file. 
1. Edit the `about.md`, `index.md`, and `posts.md` to set up the main pages for your website.
1. Markdown is a pretty powerful way of rendering rich text, see e.g. [this tutorial](https://www.writethedocs.org/guide/writing/markdown/)


## Installing navigation
In order to have some heirarchical navigation, I installed the `eleventy-navigation` plugin. 
This allows me to have heirarchical categories and to have it autogenerate some navigation for me.
Follow the instructions [here](https://www.11ty.dev/docs/plugins/navigation/) to get started.

## Installing `$$\LaTeX$$` support:
Currently on the site, I can do e.g. `$$$\frac{\mathrm{d}}{\mathrm{d}t}\int_0^t f(x) \, \mathrm{d}x $$$` using KaTeX.
Follow the instructions [here](https://benborgers.com/posts/eleventy-katex) to get started with that.

I made the following modification to the latex filter:
```
  eleventyConfig.addFilter('latex', content => {
  return content.replace(/\$\$\$(.+?)\$\$\$/g, (_, equation) => {
    const cleanEquation = equation
      .replace(/&lt;/g, '<')
      .replace(/&gt;/g, '>')

    return katex.renderToString(cleanEquation, { throwOnError: true, displayMode: true })
  }).replace(/\$\$(.+?)\$\$/g, (_, equation) => {
    const cleanEquation = equation
      .replace(/&lt;/g, '<')
      .replace(/&gt;/g, '>')

    return katex.renderToString(cleanEquation, { throwOnError: true, displayMode: false })
  })
  });
```
which adds support for both inline and display mode LaTeX. 
  
## Changing the color scheme:
In the file `public/style.css` find the line `  --color-primary: #9C2553;` and change the `#9C2553` to some other hex color.
E.g. [this colorpicker](https://www.google.com/search?client=firefox-b-1-d&q=hex+color+picker).












