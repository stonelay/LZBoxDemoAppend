require "./LZBoxDemoAppend/lib/m_git"
require "./LZBoxDemoAppend/lib/m_podfiles"
require "./LZBoxDemoAppend/lib/m_helper"

# $verbose = ARGV.include?("-v") || ARGV.include?("--verbose")

module M_JF
  class M_Repos
    def initialize(config)
      @app = config["app"]
      @version = config["app_version"]
      @podfileUtil = M_Podfiles.new(@app)
      @version_document = "m_business.versions"
      @repos = config["pod_repos"]
      @source_root = Dir.pwd
    end

    def pod_update
      fetch_pod_repos
      reset_podfile_business
      adjust_podfile_business
      do_update
    end

    def do_update
      exec_cmd_line 'env PODFILE_TYPE=DEV pod update', '集成失败'
      exec_cmd_line "open *.xcworkspace"
    end

    def cd_root
      if Dir.exist? @source_root
        Dir.chdir @source_root
      end
    end

    def reset_podfile_business
      cd_root
      if Dir.exist? @app
        Dir.chdir @app
        if File.exist? @version_document
          lines = File.readlines(@version_document).map do |line|
            if line.match(/^#/)
              line = line[1, line.length].strip
            end

            line
          end
          File.open @version_document, "w" do |file|
            lines.each do |line|
                file.write line
            end
          end
        end
      else
        puts "con not find file #{version_document} !"
      end
    end

    def adjust_podfile_business
      cd_root
      if Dir.exist? @app
        Dir.chdir @app
        if File.exist? @version_document
          lines = File.readlines(@version_document).map do |line|
            pod = line.split(":").first.strip

            if @repos.include? pod
              line = "# #{line}"
            end

            line
          end
          File.open @version_document, "w" do |file|
            lines.each do |line|
              file.write line
            end
          end
        end
      else
        puts "con not find file #{version_document} !"
      end
    end

    def fetch_pod_repo(repo)
      if Dir.exist? repo
        puts "#{repo} is already exist"
        puts "#{repo} add success"
        if Dir.exist? @app
          Dir.chdir @app do
            @podfileUtil.append_podfile_local repo
          end
        end
        return false
      end

      base_branch = M_Git.get_base_branch @version
      pod_repo_url = M_Git.repo_url repo

      puts "cloning #{repo} --branch #{base_branch}..."
      unless exec_cmd_line "git clone #{pod_repo_url} --branch #{base_branch} --single-branch --depth 10"
        if $cmd_line_last_log.include? "fatal: Remote branch #{base_branch} not found"
          puts "branch is not exist! #{base_branch}"
          puts "get default branch"
          exec_cmd_line "git clone #{pod_repo_url} --single-branch --depth 10"
        else
          puts $cmd_line_last_log
          puts "clone repo failed, exist"
        end
      end

      Dir.chdir repo do
        # exec_cmd_line "git checkout -b #{feature_branch}"
        if Dir.exist? "../#{@app}"
          Dir.chdir "../#{@app}" do
            @podfileUtil.append_podfile_local repo
          end
        end
      end
    end

    def fetch_pod_repos
      pod_local_file = "#{@app}/Podfile.local"
      if File.exist? pod_local_file
        File.unlink pod_local_file
      end
      @repos.each do |repo|
        fetch_pod_repo repo
      end
    end
  end
end
