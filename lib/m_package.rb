#!/usr/bin/ruby -w

require "xcodeproj"

module M_JF
  class M_Package
    def package
    end

    app = "LZBoxDemoAppend"
    source = "source 'https://github.com/stonelay/allPodSpec.git'"

    git_base_address = M_Git.BASE_URL
    document = "m_business.versions"
    podfile = "podfile"

    config = M_Config.new
    args = config.args

    repos = args["pod_repos"]

    mRepos = M_Repos.new(app, document, repos, nil)
    mRepos.pod_update
    # if File.exist? document
    #   lines = File.readlines(document).map do |line|
    #     pod = line.split(":").first.strip
    #     # pod
    #     line
    #   end

    #   File.open(podfile, "w") do |file|
    #     lines.each do |line|
    #       file.write line
    #     end
    #   end

    # end

    # if File.exist? document
    #   lines = File.readlines(document).map do |line|
    # pod = line.split(':').first.strip
    # unless $OPTIONS['install-all-pods']
    #   if @@OptionalPods.include? pod
    #     line = "# #{line}"
    #   end
    # end
    # line
    # end
  end
end
