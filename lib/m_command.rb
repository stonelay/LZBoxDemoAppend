require "json"
require "./LZBoxDemoAppend/lib/m_config"
require "./LZBoxDemoAppend/lib/m_repos"
require "./LZBoxDemoAppend/lib/m_helper"
require "./LZBoxDemoAppend/lib/m_uploader"
require "./LZBoxDemoAppend/lib/m_build"
require "./LZBoxDemoAppend/lib/m_version"
require "./LZBoxDemoAppend/lib/m_spec"
require "cocoapods"
require "securerandom"

module M_JF
  class M_Command
    def initialize()
      @config = M_Config.new
      @args = @config.args
      @repos = M_Repos.new(@config.args)
      @sources = "https://github.com/stonelay/allPodSpec.git"
      @bucket_name = "podrepo-1302218010"
      @source_root = Dir.pwd
      @specsources = "allSpec"
    end

    def version
      repo = get_repo_name
      chdir_source_path repo, "source path can not find, when excute lint pod"
      puts M_Version.smart_version
    end

    def make
      M_Build.build
    end

    def add
      repo = get_repo_name

      if repo
        pod_repos = @args["pod_repos"]

        if pod_repos.include? repo
          puts "repo #{repo} already included"
          exit 1
        end

        pod_repos.push repo
        @config.set "pod_repos", pod_repos

        @repos.fetch_pod_repo repo
      else
        puts "add: miss repo name"
      end
    end

    def del
      repo = get_repo_name

      if repo
        pod_repos = @args["pod_repos"]
        unless pod_repos.include? repo
          puts "repo #{repo} not include"
          exit 1
        end

        pod_repos.delete repo

        @config.set "pod_repos", pod_repos
      else
        puts "delete: miss repo name"
      end
    end

    def pod_lint
      repo = get_repo_name
      chdir_source_path repo, "source path can not find, when excute lint pod"
      cmd = "pod lib lint "
      cmd += "--allow-warnings "
      cmd += "--use-libraries "
      cmd += "--skip-import-validation "
      cmd += "--sources=#{@sources} "
      cmd += "--verbose "

      puts "excuting #{cmd} ..."
      unless exec_cmd_line cmd
        puts "lint failed"
        exit 1
      end
      chdir_source_path @source_root, "chdir root path"
    end

    def pod_package
      repo = get_repo_name
      chdir_source_path repo, "source path can not find, when excute pod_package pod"

      file_name = "#{repo}.podspec"
      unless File.exist? file_name
        puts "file #{repo} not find"
        exit 1
      end

      ori_pod_spec = Pod::Specification.from_file file_name
      version = ori_pod_spec.version
      # dependencies = ori_pod_spec.dependencies

      cmd = "pod package "
      cmd += "#{file_name} "
      cmd += "--force "
      cmd += "--no-mangle "
      cmd += "--exclude-deps "
      cmd += "--spec-sources=#{@sources}"

      unless exec_cmd_line cmd
        puts "package failed!"
        exit 1
      end

      chdir_source_path @source_root, "chdir root path"
    end

    def pod_zip
      repo = get_repo_name
      chdir_source_path repo, "source path can not find, when excute zip pod"
      chdir_zip_path repo
      file_name = "#{repo}.podspec"

      unless File.exist? file_name
        puts "file #{repo} not find"
        exit 1
      end

      pod_spec = Pod::Specification.from_file file_name
      version = pod_spec.version

      package_zip_suffix = "-" + "static" + "-" + SecureRandom.uuid
      package_zip = "#{repo}-#{version}"
      package_zip += package_zip_suffix
      package_zip += ".zip"

      unless system "7z", "a", package_zip, "./ios"
        puts "zip #{package_zip} failed!"
        exit 1
      end
      chdir_source_path @source_root, "chdir root path"
      package_zip
    end

    def pod_push_package(zip_name)
      repo = get_repo_name
      chdir_source_path repo, "source path can not find, when excute push_package pod"
      chdir_zip_path repo

      unless File.exist? zip_name
        puts "zip file #{zip_name} can not find"
        exit 1
      end

      day_time = Time.now.strftime("%Y-%m-%d")
      package_url = M_Uploader.upload_file zip_name, day_time
      puts "url is #{package_url}"
      chdir_source_path @source_root, "chdir root path"
      package_url
    end

    def pod_rewrite_spec(pod_url)
      repo = get_repo_name
      chdir_source_path repo, "source path can not find, when excute rewrite_spec pod"

      file_name = "#{repo}.podspec"

      ori_pod_spec = Pod::Specification.from_file file_name
      version = ori_pod_spec.version
      dependencies = ori_pod_spec.dependencies

      chdir_zip_path repo

      new_pod_spec = Pod::Specification.from_file file_name

      m_spec = M_Spec.new(new_pod_spec)
      m_spec.install_pod_spec pod_url

      File.open "#{repo}.podspec.json", "w" do |f|
        f.write new_pod_spec.to_pretty_json
      end
      chdir_source_path @source_root, "chdir root path"
    end

    def pod_push_podspec
      repo = get_repo_name
      chdir_source_path repo, "source path can not find, when excute push_podspec pod"
      chdir_zip_path repo

      file_name = "#{repo}.podspec.json"
      unless File.exist? file_name
        puts "file #{repo} not find"
        exit 1
      end

      cmd = "pod repo push "
      cmd += "#{@specsources} "
      cmd += "#{file_name} "
      cmd += "--skip-import-validation"

      exec_cmd_line cmd, "push err!"

      chdir_source_path @source_root, "chdir root path"

      # pod repo push allSpec BDNewRepo.podspec --skip-import-validation

      # pod_spec = Pod::Specification.from_file file_name
      # version = pod_spec.version
    end

    def pod_copy_license
      repo = get_repo_name
      chdir_source_path repo, "source path can not find, when excute pod_copy_license pod"
      chdir_zip_path repo

      license_file = File.join @source_root, "#{repo}/LICENSE"
      export_dir = Dir.pwd
      if File.exist? license_file
        FileUtils.install license_file, export_dir
      else
        FileUtils.touch "#{export_dir}/LICENSE"
      end
      chdir_source_path @source_root, "chdir root path"
    end

    def package
      pod_lint
      pod_package
      zip_name = pod_zip
      pod_url = pod_push_package zip_name
      pod_rewrite_spec pod_url
      pod_copy_license
      pod_push_podspec
      # _pod_package
      # zip_name = _zip
      # # _push_package zip_name
      # package_url = _push_package zip_name
      # rewrite_spec package_url
    end

    def chdir_source_path(path, err_msg)
      unless Dir.exist? path
        puts "err: #{err_msg}, path #{path} cannot find at local"
        exit 1
      end

      Dir.chdir path
    end

    def chdir_zip_path(repo)
      file_name = "#{repo}.podspec"

      unless File.exist? file_name
        puts "file #{repo} not find"
        exit 1
      end

      pod_spec = Pod::Specification.from_file file_name
      version = pod_spec.version

      repo_path = "#{repo}-#{version}"
      chdir_source_path repo_path, "zip path not exist"
    end

    def get_repo_name
      repo = ARGV[1]

      unless repo
        puts "need input repo name"
        exit 1
      end

      if repo.end_with? "/"
        repo = repo[0, repo.length - 1]
      end
      repo
    end

    def print_pods
      config = M_Config.new

      args = config.args
      repods = args["pod_repos"]

      puts "added repods"
      repods.each do |v|
        puts "#{v}"
      end
    end
  end
end
