module M_JF
  class M_Spec
    def initialize(spec)
      @spec = spec
      @subspecs = spec.subspecs
    end

    def install_pod_spec(pod_url)

      # install spec frameworks
      %w(frameworks weak_frameworks libraries).each do |attr|
        @spec.attributes_hash[attr.to_s] = active_attribute(attr)
      end

      # install spec dependencies
      @spec.attributes_hash["dependencies"] = external_dependencies.map do |dep|
        { dep.name => [dep.requirement.to_s].reject { |x| x == ">= 0" } }
      end.reduce({}, :merge)

      # install ios
      @spec.attributes_hash["ios"] = {
        vendored_frameworks: "ios/#{@spec.name}.framework",
        preserve_paths: "ios/#{@spec.name}.framework",
        public_header_files: "ios/#{@spec.name}.framework/Versions/A/Headers/*.h",
        source_files: "ios/#{@spec.name}.framework/Versions/A/Headers/*.h",
      }

      # install resource
      resources_path = "./ios/#{@spec.name}.framework/Versions/A/Resources"
      if Dir.exist? "#{resources_path}/Resources"
        @spec.attributes_hash["ios"]["resource"] = "ios/#{@spec.name}.framework/Versions/A/Resources/{.*,*}"
      end

      # insatll source, license
      @spec.source = { http: pod_url }
      @spec.license = { type: "proprietary", text: "text value" }
    end

    # Array<Dependency>
    def external_dependencies
      ([@spec] + active_subspecs).flat_map(&:dependencies).reject do |d|
        d.name =~ /#{Regexp.quote(@spec.name)}\//
      end
    end

    # Array<Specification>
    def active_subspecs
      @subspecs.map { |s| @spec.subspec_by_name("#{@spec.name}/#{s}", false) }.reject(&:nil?).flat_map do |subspec|
        [subspec] + subspec.all_dependencies(:ios).select { |d| d.name =~ /#{Regexp.quote(@spec.name)}\// }.map { |d| @spec.subspec_by_name(d.name, false) }
      end
    end

    # Array
    #  supported attr:
    #    :frameworks           -> Array<String>
    #    :weak_frameworks      -> Array<String>
    #    :libraries            -> Array<String>
    #    :resources            -> Array<String>
    #    :resource_bundles     -> Hash{String=>String}
    #    :source_files         -> Array<String>
    #    :public_header_files  -> Array<String>
    #    :private_header_files -> Array<String>
    def active_attribute(attr)
      result = ([@spec] + active_subspecs).flat_map do |s|
        s.consumer(:ios).send attr.to_sym
      end.uniq

      if attr.to_sym == :resource_bundles
        result = result.reduce({}, :merge)
      end

      result
    end

    def public_header_files(pod_dir)
      Dir.chdir pod_dir do
        public_header_files = active_attribute :public_header_files

        unless public_header_files.empty?
          public_header_files = Dir.glob(public_header_files)
        else
          source_files = active_attribute :source_files
          private_header_files = active_attribute :private_header_files

          public_header_files = Dir.glob(source_files).select { |f| File.extname(f) == ".h" } - Dir.glob(private_header_files)
        end

        public_header_files.map { |path| File.absolute_path(path) }
      end
    end

    def public_resources
      active_attribute :resources
    end

    def public_resource_bundles
      active_attribute(:resource_bundles)
    end
  end
end
