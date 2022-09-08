<img src='https://github.com/veelenga/bin/raw/master/dress/logo.png' width='100' align='right'>

# Dress [![Build Status](https://travis-ci.org/veelenga/dress.svg?branch=master)](https://travis-ci.org/veelenga/dress)

Cli app that makes your stdout fancy.

![](https://raw.githubusercontent.com/veelenga/bin/master/dress/demo.gif)

For now you need to create your own configuration file using [this](https://github.com/veelenga/dress/blob/master/config/default.yml) example.

## Installation

Via `brew`:

```sh
$ brew tap veelenga/tap
$ brew install dress
```

Manually:

```sh
$ git clone https://github.com/veelenga/dress && cd dress/
$ mix deps.get
$ mix escript.build
$ ./dress
```

## Usage

```sh
$ tail -f log/development.log | dress -c config/default.yml
```

## Config file

Your configuration file must be placed to `~/.dress/` folder and follow yaml format:

```yml
# ~/.dress/jacket.yml
dress:
  # colorize dates in yellow color
  dates:
    regex: '\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{3}'
    color: :yellow

  # format urls, so those will have blue color and be underlined
  urls:
    regex: '(https?:\/\/(?:www\.|(?!www))[^\s\.]+\.[^\s]{2,}|www\.[^\s]+\.[^\s]{2,})'
    format: [:blue, :underline]

  # improve time format
  time:
    regex: '(\d\d):(\d\d):(\d\d)'
    replace: '\1h\2m\3s'

  # skip some useless lines
  trash:
    regex: 'line containing this will not be shown'
    skip: true
```

And you can use it in the following way:

```sh
$ tail -f log/development.log | dress jacket
```

Be smart, automate routine stuff !
