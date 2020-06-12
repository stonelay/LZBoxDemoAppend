#!/usr/bin/ruby -w

require "xcodeproj"
require "./LZBoxDemoAppend/lib/m_helper"
require "./LZBoxDemoAppend/lib/m_config"
require "./LZBoxDemoAppend/lib/m_git"
require "./LZBoxDemoAppend/lib/m_repos"

module M_JF
  class M_Build
    # app = "LZBoxDemoAppend"
    # source = "source 'https://github.com/stonelay/allPodSpec.git'"

    # git_base_address = M_Git.BASE_URL
    # document = "m_business.versions"
    # podfile = "podfile"
    def self.build
      config = M_Config.new
      args = config.args

      mRepos = M_Repos.new(args)
      mRepos.pod_update
    end
  end
end
