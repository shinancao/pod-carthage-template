# pod-carthage-template

This is a script in Ruby used to generate a template for an open source project that support both Cocoapod and Carthage. 

## Features

* Generate a template for an open source project.
* Configure the template to support both Cocoapod and Carthage, only you need to do is to write source code.
* Automatically configure third party dependencys, if your project needs other libraries on github.
* Git as the source control management system.
* MIT license

## Getting started

* Clone this project from github.

```
git clone git@github.com:shinancao/pod-carthage-template.git
```

* If your project depends on other libraries on github, create a [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile) in `pod-carthage-template` directory. The project will use `Carthage` to manage third party libraries.

* Run `configure.rb` in `pod-carthage-template` directory.

```
cd pod-carthage-template
./configure.rb (Your project name)
```
This will generate your project directory in `pod-carthage-template` 

If your project doesn't depend on any other third party libraries, the table of contents will look like this:

<img src="http://ojx1pmrk7.bkt.clouddn.com/WX20171031-165639@2x.png" width="300" height="219">

<img src="http://ojx1pmrk7.bkt.clouddn.com/WX20171031-165703.png">

If your project depends on some third party libraries, it will produce a `xcworkspace`: 

<img src="http://ojx1pmrk7.bkt.clouddn.com/WX20171031-170251@2x.png" width="300" height="224">

<img src="http://ojx1pmrk7.bkt.clouddn.com/WX20171031-170312@2x.png" width="200" height="224">

## Other things

* Know about how to make an open source library support both Cocoapods and Carthage, and why the project is designed like this is better.

<https://shinancao.cn/2017/07/16/Project-Design-4/>

* Know about the detail implemention of this script.

<https://shinancao.cn>

* This script is deeply influenced by [CocoaPods/pod-template](https://github.com/cocoapods/pod-template) 
