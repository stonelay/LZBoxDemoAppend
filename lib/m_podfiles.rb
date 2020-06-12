# podfile.local

module M_JF
  class M_Podfiles
    def initialize(app)
      @app = app
    end

    def append_podfile_local(repo)
      open("Podfile.local", "a") do |f|
        f.puts "pod '#{repo}', path: '../#{repo}', :inhibit_warnings => false"
      end
    end
  end
end
