require 'test/unit'
require 'rsmbclient'

REMOTE_DIR = 'rsmbclient_test_dir'

class RsmbclientTest < Test::Unit::TestCase
  
  def setup
    check_smbclient_presence
    get_samba_param_from_input
    init_rsmbclient
  end
  
  def test_basic
    check_ls
    check_init_path
  end
  
  private
  
  def init_rsmbclient
    @samba = Rsmbclient.new( :domain => @domain,
                          :host => @host, 
                          :share => @share,
                          :user => @user, 
                          :password => @password)
    puts "Connection successfull,\nnow proceding with test:"
  end
  
  def check_ls
		ls = @samba.ls(".")
		assert_not_nil(ls)
	end
	
	def check_init_path
		path = @samba.path
		assert_equal(".",path)
	end
  
  def check_smbclient_presence
    answer = `smbclient --help`
    assert(answer.include?('Usage'), "No 'smbclient' tool was found on this computer,\nPlease install 'smbclient' and try again.")
  end
  
  def get_samba_param_from_input
		puts "ATTENTION!!! You need 1gb free space on your local machine and 10gb on your server for this test to run!!!"
    puts "I will need you to input some working Samba connection settings..."
    print "\n"; sleep 1
    print "host name or IP: "
    @host = $stdin.gets.chomp
    print "share name: "
    @share = $stdin.gets.chomp
    print "domain: "
    @domain = $stdin.gets.chomp
    print "user: "
    @user = $stdin.gets.chomp
    print "password: "
    @password = $stdin.gets.chomp
    puts "I will now try to connect to #{@share.to_s} for the purpose of testing rsmbclient..."
    print "\n"
  end
end