#!/bin/bash
#########################################################################
# File Name: CreateLib.sh
# Author: tsgsz
# mail: cdtsgsz@gmail.com
# Created Time: Mon Apr 29 18:03:44 2013
#Copyright [2013] <Copyright tsgsz>  [legal/copyright]
#########################################################################

iphoneOslibPath=/Users/tsgsz/Library/Developer/Xcode/DerivedData/OwbClientlibXcode-amotmuxkwdabxqflljifnmdxmxts/Build/Products/Debug-iphoneos
ihphoneSimlibPath=/Users/tsgsz/Library/Developer/Xcode/DerivedData/OwbClientlibXcode-amotmuxkwdabxqflljifnmdxmxts/Build/Products/Debug-iphonesimulator



ipOlib=$iphoneOslibPath/libOwbClientlibXcode.a
ipSlib=$ihphoneSimlibPath/libOwbClientlibXcode.a

includePath=/Users/tsgsz/Library/Developer/Xcode/DerivedData/OwbClientlibXcode-amotmuxkwdabxqflljifnmdxmxts/Build/Products/Debug-iphonesimulator/include

rm -rf ./libOwbClient.a ./include/OwbClient
mkdir ./include/OwbClient

lipo -create $ipOlib $ipSlib -output libOwbClient.a

cp -r $includePath/OwbClientlibXcode/* ./include/OwbClient/

scp -r ./* xujack@192.168.1.112:/Users/xujack/OWBClient/OwbClient/lib
