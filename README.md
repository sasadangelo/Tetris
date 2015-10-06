# Tetris 0.0.1

A simple Tetris clone written in Ruby

## Why another Tetris?
In October 2015 I attended a Ruby course and I was looking for something interesting to implement with this language. Looking around the web I found two interesting resources in which a Tetris game was implemented using this language.

These two resources are:

1. a Tetris clone written by Kamen Kitanova for the "Programming in Ruby" course at FMI, 
   University of Sofia, 2012. You can download source code [from here](http://www.gamedev.net/blog/1241/entry-2254256-tetris-in-ruby/)
2. a Tetris clone written by LLexi Leon you can [find on github here](https://github.com/llexileon/rubytetris)

I studied these resources to a better understanding of Ruby language and later I tried to do some changes just to see what happened. These two resources gave me also the possibility to learn more on Game Programming. This repository contains the result of my study that I hope to document deeply. I hope this effort will be helpful for someone else interested in Game and Ruby programming.

## Usage

Here the necessary steps to run Tetris. The assumption here is that you are using Windows as operating system. For Linux and Mac the differences should me minimal.

1. Download Github [from here](https://desktop.github.com/) and install it on your Windows.
2. Download Ruby [from here](http://railsinstaller.org/en) and install it.
3. Open a github shell
4. Run the command: _cd c:\_
5. Run the command: _git clone https://github.com/sasadangelo/Tetris.git_. The folder C:\Tetris will be created with source code inside.
6. Open a dos shell
7. Run the command: _cd c:\Tetris_
8. Run the command: _gem install gosu_. This will install the Ruby game library gosu. If you got a SSL connection problem check the troubleshooting section.
9. Run the command: _ruby TetrisGameWindow.rb_ to start the video game.

## TroubleShooting

If step 8 fails for a SSL connection problem this is a well known ruby issue. To solve it do the following:

1. Download the following [pem certificate](https://raw.githubusercontent.com/rubygems/rubygems/master/lib/rubygems/ssl_certs/AddTrustExternalCARoot-2048.pem)
2. Run the command: _gem which rubygems_. This command will print a path like this one <ruby install directory>/lib/ruby/2.1.0/rubygems.rb. You must store the pem certificate in <ruby install directory>/lib/ruby/2.1.0/rubygems/ssl_certs.
3. Run again the command: _gem install gosu_.

## Credit

Thanks to Kamen Kitanova and LLexi Leon for their original work on Tetris.
