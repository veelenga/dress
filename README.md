<img src='https://media.githubusercontent.com/media/veelenga/ss/master/dress/logo.png' width='100' align='right'>

# Dress

Cli app that makes your stdout fancy.

![](https://media.githubusercontent.com/media/veelenga/ss/master/dress/demo.gif)

## Installation

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
