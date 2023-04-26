# timely Frontend


## Instructions to run the application on a web server:

Download this project as a zip file, unzip it. Then run this command in the root folder of the newly unzipped project:
```
docker build . -t flutter_docker
```
Now run this command to make a docker container and start running it in the backround (you only need to do this once)
Note: ${PWD} prints your current directory, and works in linux shells and in powershell. You may need to manually replace it with your current directory if using cmd.
```
docker run -d -p 8080:5000 -v ${PWD}:/app --name flutter_docker flutter_docker
```
Now you can see the status of the container in docker, and you can stop it with ```docker stop flutter_docker``` and you can start it with ```docker start flutter_docker```. If you want to see what it is doing, go to docker desktop and look at the logs.

Now open up 
```
http://localhost:8080/#/
```
on your local device's internet browser to see the application's current state.

## To edit the application or work within the flutter project:

In order to work on or edit this project, you need to start by downloading flutter:

[https://docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install)

Download the stable zip file associated with your system and unzip it in the desired location to install it.


- Note that you cannot install Flutter in a directory such as ```C:\ProgramFiles\``` since that requires special privileges
- Rather, install Flutter to a path with no special characters or spaces, such as ```C:\src\flutter```

On windows, you will now want to update your path in order to run Flutter commands in the regular Windows console. To do this:
1. Click on the search bar and type 'env'
2. Select **Edit environment variables for your account**
3. Under **User variables**, check if there is an entry called **Path**.
3. a. If the entry exists, append the full path to ```flutter\bin``` using ```;``` as a separator from existing values
3. b. Otherwise, create a new user variable named ```Path``` with the full path to ```flutter\bin``` as its value


On mac, you would extract the file in the desired location by using
```
cd ~/development
unzip ~/Downloads/flutter_macos_3.38-stable.zip
```
Then you want to add the flutter tool to your path by using
```
export PATH="$PATH:[PATH_OF_FLUTTER_GIT_DIRECTORY]/bin"
```


Next you want to ensure that all dependencies are installed by using the following command in your terminal
```
flutter doctor
```

Now, if any tasks need to be performed or programs need to be downloaded this command will tell you what needs to be done.

Things you will likely need to download:
- Android Studio
    - [https://developer.android.com/studio](https://developer.android.com/studio)
    - note that you should open this and ensure that all SDK tools are installed (this takes some time to complete) before trying to redownload anything or in case any issues arrise
- Visual Studio
    - Download Visual Studio 2019 
    - [https://learn.microsoft.com/en-us/visualstudio/releases/2019/release-notes](https://learn.microsoft.com/en-us/visualstudio/releases/2019/release-notes)
    - ensure that all C++ developer tools are also installed and updated to meet this requirement
- Sign licenses
    - this requires that you open a terminal and run: ```flutter doctor --android-licenses```

## Working on the flutter project

It is highly reccomended that you do all work for the flutter project through Android Studio, which we previously linked for download. Android Studio contains android emulators that allow for easy previews of what the app currently looks like on an android phone. To begin an Android Emulator, open the device manager in Android Studio and start one of the listed Android Devices. Note that these emulators require that you have at least 10GB of space free within your computer to work propperly.


## Using Android Studio

Use the instructions and links found above to download android studio. For best use, you might also want to install virtual devices through the device manager (Device Manager > Create Device > Phone > Choose desired phone > next > Tiramisu> Finish)
This will allow you to run the flutter application on a virtual device. To use android studio with the project, download the project as a zip file and open it through the "open project" portion of android studio. Alternatively, you can can clone the project using 
```git@capstone-cs.eng.utah.edu:timely/timely-frontend.git``` 
then, open the project using android studio. If any problems arise with working in android studio or editing files, please contact Nicole Sundberg for help



### Questions and Concerns

If you have any questions, please contact Nicole Sundberg or Alex Cespedes with your installation and frontend running questions. 
