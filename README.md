# pod-carthage-template

This is a script in Ruby used to generate a template for an open source project that support both Cocoapod and Carthage. 

## Features

* Generate a template for an open source project.
* Configure the template to support both Cocoapod and Carthage, only you need to do is to write source code.
* Automatically configure third party dependencys, if your project needs other libraries on github.
* Git as the source control management system.
* MIT license

## Getting Started

* Clone this project from github.

```
git clone git@github.com:shinancao/pod-carthage-template.git
```

* If your project depends on other libraries on github, create a [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile) in `pod-carthage-template` directory. The project will use `Carthage` to manage third party libraries.

About the third party libraries your project depends on, `setup/DependencyConfigurator.rb` reads `Cartfile`, then generate s.dependency for `podspec`, their correspondence is as follows:

Cartfile   | podspec
---------- | --------
不指定版本   | 不指定版本
`== 1.0`   | `1.0`
`>= 1.0`   | `>= 1.0`
`~> 1.0`   | `~> 1.0`
"branch"   | :branch => "branch"

But if you specify branch, it will not pass the pod verification.

* Run `configure.rb` in `pod-carthage-template` directory.

```
cd pod-carthage-template
./configure.rb (Your project name)
```
This will generate your project directory in `pod-carthage-template` 

If your project doesn't depend on any other third party libraries, the table of contents will look like this:

<img src="http://ojx1pmrk7.bkt.clouddn.com/WX20171031-165639@2x.png" width="454" height="331">

<img src="http://ojx1pmrk7.bkt.clouddn.com/WX20171031-165703.png">

If your project depends on some third party libraries, it will generate a `xcworkspace`: 

<img src="http://ojx1pmrk7.bkt.clouddn.com/WX20171031-170251@2x.png" width="460" height="344">

<img src="http://ojx1pmrk7.bkt.clouddn.com/WX20171031-170312@2x.png" width="277" height="310">

## Todo List

There are still some features that can be added.

* Add `.travis.yml`
* Add test target and framework

## Other Things

* Know about how to make an open source library support both Cocoapods and Carthage, and why the project is designed like this is better.

<https://shinancao.cn/2017/07/16/Project-Design-4/>

* This script is deeply influenced by [CocoaPods/pod-template](https://github.com/cocoapods/pod-template) 