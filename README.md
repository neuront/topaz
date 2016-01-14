# Topaz Template

Topaz is a flexible templating language in Javascript.

Example:

    div#hello
        :Hello, topaz <3
        a.nav-link href='https://github.com/neuront/topaz/'
            :Fork me here

will generate (with `<` escaped)

    <div id="hello">
        Hello, topaz &#60;3
        <a class="nav-link" href="https://github.com/neuront/topaz/">
            Fork me
        </a>
    </div>

## What makes Topaz different?

The principle of Topaz is to reduce the time in writing HTML tag properties and help focus on creating web pages.

* it is a one-file library so you can simply install it by copying [the file](http://topaz.bitfoc.us/topaz.js) into your project
* it uses indentation to indicate tags block so you don't have to write the closing tags
* some properties like `id`, `class` are easy to add as you can write them in `tag-name#id.class-0.class-1` syntax
* the language can be extended by adding your own tag (call this *tag overriding*); as an example, Topaz has a built-in [twitter bootstrap](https://github.com/twbs/bootstrap) extension

## Basic Usage

For template like

    /* of course you can read the template from files or somewhere else */
    var template = [
        "div#hello",
        "    :Hello, topaz <3",
        "    % if wantFork",
        "        a.nav-link href='https://github.com/neuront/topaz/'",
        "            :Fork me here"
    ].join('\n');

Nodejs

    var topaz = require('./topaz.js').topaz;
    var output = topaz.renderHTMLBasis(template, {wantFork: true});
    console.log(output);

Browser

    var output = window.topaz.renderHTMLBasis(template, {wantFork: true});
    console.log(output);

Complete APIs are listed later.

## Syntax

### Tree Structure

There are 3 kinds of elements in Topaz:

* tag: lines that start with an identifier (which matches `/^[a-z_][0-9a-z_\-]*/i`)
* text and text block: lines that start with a colon (`:`), or lines between two text block mark (`:::`) lines
* expressions as text and controllers: lines that start with a percentage mark (`%`)

elements with same indentations will be siblings, and an element that is followed by other elements with more indentation is the parent of those followers.

Here is a overview example

    div#parent-0
        span
            % if some_condition
                :Go ahead
            % else
                :Stay here
    div#parent-1
        textarea
            :::
            The quick brown fox
            jumps over the lazy
            dog
            :::

It contains 2 root elements `div#parent-0` and `div#parent-1`, which are siblings. The elment `span` is the child of `div#parent-0` and contains a branch controller (the `else` matches the `if` because they have the same indentation and are therefore actually two components of one *branch* element). The `textaree`, as the child of `div#parent-1`, contains a *text block* whose content is `The quick ... dog`.

### Tag Components

A tag is a tag name before the `id`, `class`es and attributes. You can write any of the followings

    div#myDiv.cls-0.cls-1 style='text-align: center'
    div.cls-0 #myDiv style='text-align: center' class='cls-1'
    div id="myDiv" .cls-0 style='text-align: center' class='cls-1'

attributes without values are tag *arguments* that may be used when building user-overriding tags. For example

    icon file
    input#myInput disabled

`file` and `disabled` are the arguments, not attributes.

### Template Variables and Expression

When you need to determinate a attribute value later, you may use template variable by wrap the value in a pair of parentheses, like

    input value=(val) placeholder=('Input value for: ' + ph)
    div.('col-sm-' + width if width else '')

if you render it with (mark the second argument given to `topaz.renderHTMLBasis`)

    var output = topaz.renderHTMLBasis(template, {
        val: 91,
        ph: 'weight',
        width: 4
    });

you will get

    <input value="91" placeholder="Input value for: weight">
    <div class="col-sm-4">
    </div>

Expressions include

* a decimal number or a string literal
* a identifier for variable name, except keywords `for if else in`
* arithmetics, including binary `+ - * / % < > <= >= == != && ||` (`==` and `!=` are strict) and unary `+ - !`
* member access, like `aaa.bbb.ccc` or `aaa['bbb'][ccc + ddd]`
* list, like `[0, 1, 2, 3]`
* conditional expression, like `consequence if predicate else alternative`

### Text Blocks

When a line starts with a triplet of colons (`:::`), the following lines are treated as text, unless another `:::` line appears, or a line with less indentation than the beginning `:::` line. You can specify some arguments to control HTML escape, space trim and/or end-of-line character like

    ::: left=keep right=trim escape=yes eol=lf
    text
    :::

The valid arguments are

* left
    * keep (default): keep all spaces before the text in each line
    * trunc: remove a number of spaces in each text line, that the number is the indentation level of the beginning `:::`
    * trim: remove all spaces before the text in each line
* right
    * trim (default): remove all trailing spaces in each line
    * keep: keep all trailing spaces in each line
* escape
    * yes (default): escape all text
    * no: don't escape all text; this is also an approach to write raw HTML in Topaz
* eol
    * lf (default): place a `\n` after each line
    * br: place a `<br>` tag after each line
    * off: link all content together without delimiter

### Expression Value as Text

If a line starts with a percentage and then an expression, the value of the expression will be escaped and rendered, like

    span
        % someText + ' foo ' + otherText

### Control Flows

Branches and object-based loops are supported.

Syntax for a branch is like

    % if predicate
        SOME_CONTENT
    % else
        OTHER_CONTENT

`predicate` should be an expression, and `else` is optional. In Topaz, empty list and object, e.g. `[]` and `{}`, are treated as false.

Syntax for an object-based loop is like

    % for value in list
        CONTENT
    % for key, value in list
        CONTENT

`key` and `value` could be any identifiers, as they have been declared after the `for` you can reference them in the loop body; `list` should be an expression.

If you iterate over a list, `key` comes as "0", "1", etc, and `value` comes as each element in the list. If you iterate over an object otherwise, `key` comes as the property names of the object and `value` as the property values.

### Include

To include another template and place the inside elements at the position of the include.

Syntax

    % include path [templ_args]

The `path` should be a string, identifier (the same as a string), or an expression. The optional `templ_args` should be a dictionary value, which will be applied to the included template.

For more detail, please go to read include API.

## APIs

### Quick Render APIs

* `renderHTMLBasis(text, vars={})`
* `renderBootstrap(text, vars={})`

`text` argument is template content and `vars` argument (optional) is the template variables.

Both of them render template into HTML. The difference is `renderBootstrap` does some tag overriding for twitter bootstrap and font-awesome.

### Detailed Render APIS

* `Builder(vars={})`
* `HTMLBasisBuilder(vars={})`
* `BootstrapFontawesomeBuilder(vars={})`

`vars` argument (optional) is the template variables, which could also be reset after the builder get created.

Each of the `Builder` instance has similar APIs but they does different tag overridings (those overridings will be listed later). Here are they

* `buildAndRenderText(text)`: renders `text` into HTML
* `buildTextToElementsSync(text)`: builds `text` into elements tree and returns it, without applying template variables
* `buildTextToElements(text, callback(error, result))`: asynchronous version of `buildTextToElementsSync`
* `applyVariablesToSync(elements)`: apply template variables to elements and returns the applied
* `applyVariablesTo(elements, callback(error, result))`: asynchronous version of `applyVariablesToSync`
* `renderApplied(elements)`: render applied elements into HTML
* `resetVariables(vars)`: reset the template variables of the builder
* `setAppliedFunc(tagName, callback(element, builder))`: set a callback function that is called to each element of `tagName` after applied; the callback shall return an applied element
* `setRenderFunc(tagName, callback(element, builder))`: set a callback function that is called to render each element of `tagName` before rendering to text; the callback shall return a render result as string

### Callback for Include

If `% include` is used in a template, the builder should implement either `includeTemplateSync` or `includeTemplate`, depends on which apply function (`applyVariablesToSync` or `applyVariablesTo`) is used to apply variables to elements.

The `includeTemplateSync(path)` function takes the template **path** as parameter and should return a template string as result; and the `includeTemplate(path, callback(error, result))` takes the template path as parameter and should pass a template string to the callback as the second argument.

The **path** parameter don't have to be mapped to any file system path or URL, as they are just a template name for the builder. Once a template is loaded, it will be cached in the builder, but can be cleared at once by `Builder.clearCachedInclude()`.

The functions `renderHTMLBasis` and `renderBootstrap` use the default builder so they cannot handle `include` elements.

## Built-in Tag Overridings

`HTMLBasisBuilder` contains tag overridings as

* `jsfile [file-path]`: generates a `script` tag, with `type=text/javascript` and `src=[file-path]`
* `cssfile [file-path]`: generates a `link` tag to include a CSS file
* `js`: the following lines will be Javascript content of a `script` tag, and won't be ever escaped, until next `:::` line
* `css`: the following lines will be CSS content of a `style` tag, and won't be ever escaped, until next `:::` line
* `html5`: generates `<!doctype html><html>`
* `charset [encoding]`: generates a `meta` tag of charset

`BootstrapFontawesomeBuilder` extends tag overridings of `HTMLBasisBuilder` by adding

* `icon [type]`: generates an `i` tag with classes `fa fa-[type]`, for [font-awesome](http://fortawesome.github.io/Font-Awesome/)
* `btn [color=?] [type=?]`: generates a `button` tag with classes `btn btn-[color]` and `type=[type]`, by default `color` is `default` and `type` is `button`
* `input`: generates an `input` tag with classes `form-control` and `type=text`
* `passwd`: generates an `input` tag with classes `form-control` and `type=password`
* `textarea`: generates a `textarea` tag with classes `form-control`
* `select`: generates a `select` tag with classes `form-control`
* `checkbox inline?` / `radio inline?`: `inline` argument is optional; if provided, generated as inline tags, orelse a `div` block; [reference here](http://www.w3schools.com/bootstrap/bootstrap_forms_inputs.asp)
* `form-h`: generates a `form` tag with classes `form-horizontal form-submit`
* `container`: generates a `div` tag with class `container`
* `row`: generates a `div` tag; if its parent is `form-h`, it contains class `form-group`, otherwise `row`
* `grid [size=?] [offset=?]`: generates a `div` tag with class `col-sm-[size]` (default `size` is 4), `col-offset-[offset]` if `offset` is set and greater than 0
* `grid-s [size=?] [offset=?]` / `grid-c [size=?] [offset=?]`: generates a `label` tag, with `size` and `offset` args affecting the same way with `grid` tag, and `-s` contains class `form-control-static` while `-c` contains `control-label`
* `lbl [color=?]`: generates a `span` tag with classes `label label-[color]`
* `alert [color=?]`: generates a `div` tag with classes `alert alert-[color]`, color is default `info`
* `breadcrumb`: generates a `ol` tag with class `breadcrumb`, the children of whom would be wrapped in an `<a>` in a `<li>`, expect the last child, who will be replaced as a `<li class='active'>`
* `modal`: generates a [bootstrap modal](http://www.w3schools.com/bootstrap/bootstrap_modal.asp), whose children are placed under the `div.modal-body`
    * `title`: as a child of a `modal` tag, it will be placed under the `div.modal-head` in an `h4` tag
