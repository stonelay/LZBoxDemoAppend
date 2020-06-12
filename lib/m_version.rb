module M_JF
  class M_Version
    def self.smart_version
      `git pull`
      `git fetch --unshallow 2>&1 >/dev/null`
      `git fetch --tags 2>&1 >/dev/null`

      tag = `git branch`.match('\* \(HEAD detached at (\d+\.[\d\.]+)\)')[1] rescue nil
      return tag unless tag.nil?

      tag = `git describe --abbrev=0 --tags 2>/dev/null`.strip
      return tag if $?.success?

      tag = `git describe --abbrev=0 --tags 2>/dev/null`.strip

      if $?.success? then tag else "10.0.1" end
    end
  end
end
