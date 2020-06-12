#!/bin/sh

echo go to `dirname $0`
cd `dirname $0`
echo `pwd`

appName="beibei"
curDir=`pwd`
distDir="$curDir/buildipa_yueyu"
codeIdentify="\"iPhone Distribution: Hunet Inc.\""
configuration='Develop'
workspace='BeiBeiAPP.xcworkspace'
tool='xcodebuild'

$tool clean -workspace $workspace -scheme $appName -configuration $configuration -sdk iphoneos SYMROOT=`pwd`/build_yueyu

if [ -d $distDir ];then
    rm -rf "$distDir"
    mkdir $distDir
else
    mkdir $distDir
fi

developDir="build_yueyu/Develop-iphoneos"
channel="$curDir/channelId.dat"

rm -rdf "$developDir"

$tool -workspace $workspace -scheme $appName -configuration $configuration -sdk iphoneos build SYMROOT=`pwd`/build_yueyu
# xcodebuild -target $appName -configuration Distribution -sdk iphoneos build CODE_SIGN_IDENTITY="iPhone Distribution: Hunet Inc."
echo "xcode build completed-----------------"
# GCC_PREPROCESSOR_DEFINITIONS="API_TYPE=$i"

cp -R "$developDir/$appName.app" "$distDir/$appName.app"

cd "$distDir/$appName.app"

while read channelId
do
echo $channelId > channelId.data

/usr/bin/xcrun -sdk iphoneos PackageApplication -v "$distDir/$appName.app" -o "$distDir/$channelId.ipa" --sign "09E378E966D47195A553BE0EF9F0790D4997A9B5"
done < $channel

