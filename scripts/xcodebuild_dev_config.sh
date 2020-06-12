#!/bin/sh

#使用方法：bash -l ./xcodebuild_dev_config.sh

# Your configuration information

target_name="LZBoxDemoAppend" # 编译目标名称
workspace_name="${target_name}.xcworkspace" # 有效值 ****.xcodeproj / ****.xcworkspace (cocoapods项目)
work_type="workspace" # 有效值 project / workspace (cocoapods项目)
# api_token="a31b3b5d47ab8e8bc885b053e9e6f56a" # fir token
# 29559340c67ed17c670283d41d778457 测试
# a31b3b5d47ab8e8bc885b053e9e6f56a 我的
sctipt_path=$(cd `dirname $0`; pwd)
echo sctipt_path=${sctipt_path}
work_path=${sctipt_path}/..
rm -rf ${work_path}/build

#cd ../
#pod install --no-repo-update
#cd ${sctipt_path}

out_sub_path=`date "+%Y-%m-%d-%H-%M-%S"`
out_base_path="xcode_build_ipa_dev"
out_path=${work_path}/${out_base_path}/${out_sub_path}
mkdir -p ${out_path}


if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then
source $HOME/.rvm/scripts/rvm
rvm use system
fi

echo "xcode build begin-----------------"
xcodebuild -$work_type ${work_path}/$workspace_name -scheme $target_name -configuration Debug -sdk iphoneos clean
xcodebuild archive -$work_type ${work_path}/$workspace_name -scheme $target_name -configuration Debug -archivePath ${out_path}/$target_name.xcarchive

xcodebuild -exportArchive -archivePath ${out_path}/$target_name.xcarchive -exportPath ${out_path} -exportOptionsPlist ${sctipt_path}/xcodebuild_dev_config.plist -allowProvisioningUpdates

echo "xcode build completed-----------------"

echo ${out_path}/$target_name.ipa

# if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then
# source ~/.rvm/scripts/rvm
# rvm use default
# fi

# fir p ${out_path}/$target_name.ipa -T $api_token -c 1.部分界面

exit 0
