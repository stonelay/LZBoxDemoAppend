#!/bin/sh

#使用方法：bash -l ./xcodebuild_dev_config.sh

# Your configuration information

workspace_name="Jietiao.xcworkspace" # 有效值 ****.xcodeproj / ****.xcworkspace (cocoapods项目)
target_name="Jietiao" # 编译目标名称
work_type="workspace" # 有效值 project / workspace (cocoapods项目)
api_token="29559340c67ed17c670283d41d778457" # fir token


sctipt_path=$(cd `dirname $0`; pwd)
echo sctipt_path=${sctipt_path}
work_path=${sctipt_path}/..
rm -rf ${work_path}/build

#cd ../
#pod install --no-repo-update
#cd ${sctipt_path}

out_sub_path=`date "+%Y-%m-%d-%H-%M-%S"`
out_base_path="xcode_build_ipa_dis"
out_path=${work_path}/${out_base_path}/${out_sub_path}
mkdir -p ${out_path}


if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then
source $HOME/.rvm/scripts/rvm
rvm use system
fi

xcodebuild -$work_type ${work_path}/$workspace_name -scheme $target_name -configuration Release -sdk iphoneos clean
xcodebuild archive -$work_type ${work_path}/$workspace_name -scheme $target_name -configuration Release -archivePath ${out_path}/$target_name.xcarchive

xcodebuild -exportArchive -archivePath ${out_path}/$target_name.xcarchive -exportPath ${out_path} -exportOptionsPlist ${sctipt_path}/xcodebuild_dev_config.plist

echo ${out_path}/$target_name.ipa

if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then
source ~/.rvm/scripts/rvm
rvm use default
fi

fir p ${out_path}/$target_name.ipa -T $api_token -c 发布Release版本，修改添加银行卡改为更换银行卡

exit 0
