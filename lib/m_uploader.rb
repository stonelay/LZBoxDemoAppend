##
# tencel cloud
##

module M_JF
  class M_Uploader
    def self.upload_file(file_name, path)
      unless file_name
        puts "upload failed file name is null."
        exit 1
      end

      unless path
        puts "upload failed path name is null."
        exit 1
      end

      upload_path = "#{path}/#{file_name}"
      puts upload_path
      st = system "coscmd", "upload", file_name, upload_path
      unless st
        puts "upload failed #{st}"
        exit 1
      end
      puts "upload #{file_name} success"

      prefix = "https://"
      bucket_name = "podrepo-1302218010"
      regin = "shanghai.myqcloud.com/"

      url_path = "#{prefix}#{bucket_name}.cos.ap-#{regin}#{upload_path}"
    end
  end
end
