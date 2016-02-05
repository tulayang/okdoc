Install
---------

### nim

    $ sh build.sh
    $ echo 'export PATH=$PATH:$your_install_dir/bin' >> ~/.profile
    $ source ~/.profile
    $ nim

<span>

    $ git clone -b master git://github.com/nim-lang/Nim.git
	$ cd Nim
	$ git clone -b master --depth 1 git://github.com/nim-lang/csources
	$ cd csources && sh build.sh
	$ cd ..
	$ bin/nim c koch
	$ ./koch boot -d:release
    
    $ git pull                                                            # 更新
    $ ./koch boot -d:release

### nimble

    $ git clone https://github.com/nim-lang/nimble
    $ cd nimble
    $ nim c -r src/nimble install
    $ echo 'export PATH=$PATH:$HOME/.nimble/bin' >> ~/.profile
    $ source ~/.profile
    $ nimble update
