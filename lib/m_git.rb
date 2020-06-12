$verbose = ARGV.include?("-v") || ARGV.include?("--verbose")

module M_JF
  class M_Git
    @@base_url = "https://github.com/stonelay"
    def self.BASE_URL
      @@base_url
    end

    def self.repo_url(repo)
      "#{@@base_url}/#{repo}.git"
    end

    def self.get_base_branch(version)
      unless version
        return "master"
      end
      return "dev/#{version}"
    end
  end
end
