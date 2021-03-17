
  
    
# app_starter      
 A package that helps you start a flutter application from a specific template      
      
## Getting Started    
    
 Simply activate the package:    
```sh  
flutter pub global activate app_starter    
```  
## How to use it ?    
 Place yourself where you want to create your app and then simply run:    
    
  ```sh  
 flutter pub run app_starter --name <package_identifier> --org <organisation> --template <template_git_repository>  
```  
  
 For example:    
    
```sh  
 flutter pub run app_starter --name toto --org io.example --template https://github.com/ThomasEcalle/flappy_templateUsing abbreviation:    
```  
Or, more concise:  
```sh  
 flutter pub run -n toto -o io.example -t https://github.com/ThomasEcalle/flappy_template  
```  
  
## Arguments    
 | key | abbreviation | description | default value |    
| ---- | -- | -- | --  |    
| name | n | the dart package identifier | example |    
| org | o | the organisation identifier | com.example |    
| template | t | the git repository of your template | https://github.com/ThomasEcalle/flappy_template |    
    
 ## How does it works ?  
 1. This tool will **create** a fresh new flutter application using the basic `flutter create` command from the flutter version installed on your computer.  
 2. It will get your model repository and **clone** it.  
 3. Then, it will ***copy and paste*** the  `/lib` and `/test` folders, as well as the `pubspec.yaml` file from your model repository to your new app.  
 4. Fourth step: it will **change all imports** in these directories (and in pubspec) in order to put the right new dart package identifier.  
 5. Finally, the tool will delete temporary cloned repository and... **you are good to go** !  
   
        
## Motivation    
 As a Flutter developper, you may have to create new apps very often.    
Each time you create an application, you usually have to do the same things:    
    
 - Create the app with the right name and organization    
 - Put on the architecture you are used to work with    
 - Put all the dependencies you are used to work with    
 - (depending on your needs): create several flavors    
 - etc.    
    
Being a freelance developer and having multiple customers or being a tech lead in a company running several apps, this kind of scenario may happen a lot in your life.    
  
This package is here to make you **save some time** on these processes.    
    
## Several philosophies    
 Now that you want to automate these processes, you have to choose **how** to do it.    
### Using an already existing "starter" You could use an already existing starter as the famous one from very good ventures : https://github.com/VeryGoodOpenSource/very_good_cli    
    
    
Let's be honest : **this is a good starter** !   
  
But, you can't really customize it depending on your needs.. and developers often have different needs ! Different philosophies on architecture, on dependencies, etc.    
### Cloning a repository  and "change the name"  
An other option that I previously used was to create a model repository.    
This repository would implement all I need for a "basic" app.    
Then, I just had to clone it and change the app's name.    
    
But... that was **never as simple**.    
Creating a flutter app with the command line automate a bunch of things for you. From putting the right packages on Android & iOS to the right names in configurations files, and a lot of other things.    
    
So, to "just change the name of your app" is never as simple as this.    
Without mentioning the fact that the number of configuration files which need to be update may evolve as Flutter evolve itself !    
    
### Using app_starter    
 I wanted to create a way to reunite the best of the 2 worlds:    
    
- Create the app using flutter's line command to prevent developer from putting his hands in all configuration files    
- Cloning architecture from a model repository    
    
Flutter evolves ?    
No problem, you will still be able to create a new app cloning your base architecture without any effort 🚀  
  
### About app flavors  
  
Flavors are often really important in app develoment.  
Every app I develop use, at least, a `dev` and a `prod` flavor, some times more.  
But creating flavors is not really simple (see the [official doc](https://flutter.dev/docs/deployment/flavors))  
  
On Android, it is quite simple.

On iOS ... well... it is not "hard", but it takes you a little bit of time to be sure everything is ok.  
  
I didn't want to force app_starter users to use flavors.  

Also, automate flavors creation is not really easy.  
  
This is why, in the default template, I use the wonderfull package [flutter_flavorizr](https://pub.dev/packages/flutter_flavorizr)

I just have to say which flavors I would like to create in the pubspec and then, after app_starter work, I would be able to generate these flavors for each app using the [flutter_flavorizr](https://pub.dev/packages/flutter_flavorizr) package 🎉  
  
As you can see, the way app_starter works enable each developer to make its own starter easily, without the constraint to base itself on someone else "template".  
  
Feel free to create your own templates and to play with it !