#!/usr/bin/ruby -w

require 'xcodeproj'

class CreateProj
    app_project = Xcodeproj::Project.new('App.xcodeproj')
    app_project.new_target(:dynamic_library, 'App', :ios, '8.0')
    app_project.recreate_user_schemes
    Xcodeproj::XCScheme.share_scheme(app_project.path, 'App')

    app_project.root_object.attributes["LastUpgradeCheck"] = "0820"

    swiftc_version = '4.0'
    
    app_project.targets.each do |target|
          target.build_configurations.each do |c|
          c.build_settings["OTHER_LDFLAGS"] ||= ""
          c.build_settings["OTHER_LDFLAGS"] += " $(inherited) -Wl,-U -Wl,__mh_execute_header"
          c.build_settings["ENABLE_BITCODE"] = "NO"
          c.build_settings["CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES"] = "YES"
          c.build_settings["SWIFT_VERSION"] ||= swiftc_version
          c.build_settings["ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES"] = "NO"
          c.build_settings["CLANG_WARN_INFINITE_RECURSION"] = "YES"
          c.build_settings["CLANG_WARN_SUSPICIOUS_MOVE"] = "YES"
          c.build_settings["ENABLE_STRICT_OBJC_MSGSEND"] = "YES"
          c.build_settings["GCC_NO_COMMON_BLOCKS"] = "YES"
          c.build_settings["CLANG_WARN_DOCUMENTATION_COMMENTS"] = "NO"
          c.build_settings["CLANG_MODULES_AUTOLINK"] = "NO"     
        end
    end

    source_file = 'source.m'
    FileUtils.touch source_file

    source_file = yield File.absolute_path(source_file) if block_given? # block 里可以随意更改文件内容甚至文件名字，返回文件完整路径
    source_file_ref = app_project.new_group('App').new_file(source_file)

    swift_source_file = 'swift.swift'
    File.open swift_source_file, 'w' do |f|
        f.write <<-EOF
import Foundation
import UIKit
          EOF
    end

    swift_source_file_ref = app_project.new_group('App').new_file(swift_source_file)
    app_target = app_project.targets.first
    app_target.add_file_references([source_file_ref, swift_source_file_ref])
    app_project.save

    update_command = 'pod update'
    success = Kernel.system update_command

    cmd_base = "set -o pipefail && nice xcrun xcodebuild clean build -workspace App.xcworkspace -scheme App -configuration Release CODE_SIGN_IDENTITY=\"\" CODE_SIGNING_REQUIRED=NO"
    cmd_base += " -derivedDataPath build"
    cmd_base += " COMPILER_INDEX_STORE_ENABLE=NO"
    cmd_base += " TARGETED_DEVICE_FAMILY=1 OTHER_CFLAGS=\'-fembed-bitcode -Qunused-arguments -Wl,-U -Wl,__mh_execute_header\'"

    archs = %w(x86_64 i386 arm64 armv7)
    archs_device = archs.select do |a|
        a =~ /arm/
    end

    archs_simulator = archs.select do |a|
        a == 'i386' || a == 'x86_64'
    end

    cmd_tail = if !ENV["VERBOSE"] && `command -v xcpretty`.length > 0 then " | tee build.log | xcpretty --color" else " | tee build.log" end

    unless archs_simulator.empty?
        simluator_name = "iPhone 6s"
        cmd_simulator = cmd_base + " ARCHS=\"#{archs_simulator.join " "}\" -sdk iphonesimulator -destination \"platform=iOS Simulator,name=#{simluator_name}\"" + cmd_tail
        system(cmd_simulator)
        system "rm", "-rf", ".tmp"
        system "mkdir .tmp"
        system "mv", "build/Build/Products/Release-iphonesimulator", ".tmp/"
    end

    unless archs_device.empty?
        cmd_device = cmd_base + " ARCHS=\"#{archs_device.join " "}\" -sdk iphoneos -destination \"generic/platform=iOS\"" + cmd_tail
        system(cmd_device)
    end

    unless archs_simulator.empty?
        system "mv", ".tmp/", "build/Build/Products/Release-iphonesimulator"
    end

end

