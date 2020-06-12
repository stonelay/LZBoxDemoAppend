
source 'https://github.com/stonelay/allPodSpec.git'

platform :ios, '8.0'

target 'LZBoxDemoAppend' do
  
  business_podfile = "m_business.versions"
  
  File.foreach(business_podfile) do |line|
    
    m = line.split(':')
    repo = m[0]
    subs = m[1]
    
    unless repo.match(/^#/)
      if subs
        git_url = "https://github.com/stonelay/#{repo}.git"
        if subs.match(/^dev/)
          puts "pod #{repo}, git #{git_url}, branch #{subs}"
          pod repo, :git => git_url, :branch => subs
          else
          puts "pod #{repo}, tag #{subs}"
          pod repo, subs
        end
      end
    end
  end
  
  local_podfile = "Podfile.local"
  eval(File.read(local_podfile)) if File.exist? local_podfile
  
end
