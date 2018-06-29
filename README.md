# Maxy::Gen

A commandline tool to generate max patches in an emmet-like fashion

![](https://s3.eu-central-1.amazonaws.com/maxy-gen/maxygen-demo-v0.3.0.gif)

## Installation and Upgrading

_Important! You have to repeat this procedure when upgrading!_

Requires `ruby` installed, of course. This gem was built with v.2.3.3.

Install the gem:

    $ gem install maxy-gen       
    
This version depends on your local Max installation. Install max object definitions like so:

    $ maxy-gen install
    
Or simply

    $ maxy-gen i
    
You will be asked for the path to your `refpages` directory. Just hit Enter if you installed Max in your Applications folder.

Note: This is totally untested on Windows!    

## Usage

Use an [emmet](https://emmet.io/)-like pattern to generate a max patch, e.g.

    $ maxy-gen generate 'inlet-(\-{3.14}-print)+(trigger{b}-(outlet+print))' > complex_grouping.maxpat
    
(or shorter, `maxy-gen g ...`)
        
... and open it in Max. 

As of now you can use 

- `-` dashes to indicate patch chords 
- `=` equal signs to connect a row (as in `t b b`) to multiple objects at once
- `<` less than signs to connect a single outlet to an object with many inputs (as in `pack 1 2 3`)
- `{}` curly braces to denote arguments passed to objects
- `+` to denote sibling objects
- `(...)` to group objects together (see demo above)

A couple of objects need escaping (with `\`), because some characters are taken, obviously. These are:

- `\==`
- `\<`
- `\<=`
- `\-`
- `\+`
- `\<<`
- `\*`
- `\==~`
- `\<=~`
- `\<~`
- `\-~`
- `\+=~`
- `\+~`
- `\*~`

     

This gem is under heavy development!

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/julianrubisch/maxy-gen.

Please include:
- your platform
- your ruby version
- a description of what didn't work
- the patch produced by maxy-gen
- the patch as you'd have expected it

## Support
This is a pure side project and depends on your support!

If you'd like to support the development of `maxy-gen` and my other projects, take a look at [https://www.patreon.com/znibbles](https://www.patreon.com/znibbles)
