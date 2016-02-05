1. Download Android SDK from https://developer.android.com

2. Install

3. Аdd system environment variable

       $ vi /etc/profile

         export ANDROID_HOME=/home/king/android/android-studio/sdk
         export PATH=${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

       $ source /etc/profile 
       $ android update sdk
       $ adb

