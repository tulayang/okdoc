## Install


1. System Requirements

   * Ubuntu 14.04 LTS
   * Node.js 0.10.26 or a later stable official release except Node.js 0.10.34
     $ sudo apt-get install nodejs-legacy
   * G++ compiler
     $ sudo apt-get install g++
   * JDK 7 or a later stable official release
     $ sudo aptitude install oracle-java8-installer
   * Apache Ant 1.8 or later
     $ sudo apt-get install ant
   * Android SDK 19 or later
   * (Optional) Genymotion to expand your testing options

2. Install the runtime libraries for the ia32/i386 architecture

       $ sudo aptitude install lib32z1 lib32ncurses5 lib32bz2-1.0 libstdc++6:i386

3. Install the NativeScript CLI

       $ sudo npm i -g nativescript

4. Create your app


## Create


1. Create app

       $ tns create app

2. Add target development platforms

       $ tns platform add ios
         tns platform add android

3. You can quickly check how your blank project looks like in the emulator or on device

       $ tns run ios --emulator
         tns run android --emulator

       $ tns run ios
         tns run android

       $ tns debug andorid --debug-brk
