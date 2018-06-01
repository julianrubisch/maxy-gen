# Maxy::Gen

A commandline tool to generate max patches in an emmet-like fashion

![](https://s3.eu-central-1.amazonaws.com/maxy-gen/maxygen-demo.gif)

## Installation

Requires `ruby` installed, of course. This gem was built with v.2.3.3.

Install the gem:

    $ gem install maxy-gen       

## Usage

Use an [emmet](https://emmet.io/)-like pattern to generate a max patch, e.g.

    $ maxy-gen generate 'cycle~{440.}-*~{0.2}-ezdac~' > test.maxpat
    
        
... and open it in Max. 

As of now you can use 

- `-` dashes to indicate patch chords 
- `{}` curly braces to denote arguments passed to objects

This gem is under heavy development and needs a library of max objects to function. 

This early prototype supports
- `cycle~`
- `ezdac~`
- `sig~`
- `*~` 
     
- (later, you will be able to use escaped identifiers, such as `\-~`, because `-{}` are taken, obviously )     

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/julianrubisch/maxy-gen.

Please include:
- a description of what didn't work
- the patch produced by maxy-gen
- the patch as you'd have expected it

## Support
This is a pure side project and depends on your support!

If you'd like to support the development of `maxy-gen` and my other projects, take a look at [https://www.patreon.com/znibbles](https://www.patreon.com/znibbles)