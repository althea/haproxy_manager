require File.expand_path('../spec_helper', __FILE__)
module HAProxyManager
  describe Instance do
    before(:all) do
      @stat_response = ["# pxname,svname,qcur,qmax,scur,smax,slim,stot,bin,bout,dreq,dresp,ereq,econ,eresp,wretr,wredis,status,weight,act,bck,chkfail,chkdown,lastchg,downtime,qlimit,pid,iid,sid,throttle,lbtot,tracked,type,rate,rate_lim,rate_max,check_status,check_code,check_duration,hrsp_1xx,hrsp_2xx,hrsp_3xx,hrsp_4xx,hrsp_5xx,hrsp_other,hanafail,req_rate,req_rate_max,req_tot,cli_abrt,srv_abrt,",
        "foo-farm,preprod-app,0,9,0,60,60,137789,34510620,3221358490,,0,,3,720,0,0,UP,12,1,0,562,143,45394,255790,,1,1,1,,113890,,2,0,,88,L7OK,200,20,0,134660,2028,147,230,0,0,,,,20,6,",
       "foo-farm,preprod-bg,0,0,0,3,30,31,14333,380028,,0,,0,9,4,2,DOWN,5,1,0,4,10,2453494,4518397,,1,1,2,,6,,2,0,,2,L4CON,,0,0,16,0,0,0,0,0,,,,1,0,",
       "foo-farm,preprod-test,0,0,0,0,30,0,0,0,,0,,0,0,0,0,DOWN,5,1,0,0,1,5017534,5017534,,1,1,3,,0,,2,0,,0,L4CON,,0,0,0,0,0,0,0,0,,,,0,0,",
       "foo-https-farm,preprod-app,0,0,0,3,60,6219,2577996,71804141,,0,,1,30,3,0,UP,12,1,0,559,137,45394,255774,,1,2,1,,1948,,2,0,,2,L7OK,200,109,0,5912,181,11,29,0,0,,,,501,0,",
       "foo-https-farm,preprod-bg,0,0,0,0,30,0,0,0,,0,,0,0,0,0,DOWN,5,1,0,4,4,2453494,4518368,,1,2,2,,0,,2,0,,0,L4CON,,0,0,0,0,0,0,0,0,,,,0,0,", 
       "foo-https-farm,preprod-test,0,0,0,0,30,0,0,0,,0,,0,0,0,0,DOWN,5,1,0,0,1,5017532,5017532,,1,2,3,,0,,2,0,,0,L4CON,,0,0,0,0,0,0,0,0,,,,0,0,"]
      @info_response = ["Name: HAProxy", "Version: 1.5-dev11", "Release_date: 2012/06/04", "Nbproc: 1", "Process_num: 1", "Pid: 4084", "Uptime: 58d 3h50m53s", "Uptime_sec: 5025053", "Memmax_MB: 0", "Ulimit-n: 40029", "Maxsock: 40029", "Maxconn: 20000", "Hard_maxconn: 20000", "Maxpipes: 0", "CurrConns: 0", "PipesUsed: 0", "PipesFree: 0", "ConnRate: 0", "ConnRateLimit: 0", "MaxConnRate: 69", "Tasks: 10", "Run_queue: 1", "Idle_pct: 100", "node: some machine on ec3", "description: Our awesome load balancer"]
      @allstats = ["# pxname,svname,qcur,qmax,scur,smax,slim,stot,bin,bout,dreq,dresp,ereq,econ,eresp,wretr,wredis,status,weight,act,bck,chkfail,chkdown,lastchg,downtime,qlimit,pid,iid,sid,throttle,lbtot,tracked,type,rate,rate_lim,rate_max,check_status,check_code,check_duration,hrsp_1xx,hrsp_2xx,hrsp_3xx,hrsp_4xx,hrsp_5xx,hrsp_other,hanafail,req_rate,req_rate_max,req_tot,cli_abrt,srv_abrt,",
        "foo-farm,FRONTEND,,,0,150,2000,165893,38619996,3233457381,0,0,6504,,,,,OPEN,,,,,,,,,1,1,0,,,,0,0,0,69,,,,0,136147,2128,6654,20955,9,,0,144,165893,,,",
        "foo-farm,preprod-app,0,9,0,60,60,139066,34839081,3222850212,,0,,3,725,0,0,UP,10,1,0,583,148,10893,257935,,1,1,1,,114847,,2,0,,88,L7OK,200,150,0,135827,2128,147,230,0,0,,,,20,11,",
        "foo-farm,preprod-bg,0,0,0,3,30,31,14333,380028,,0,,0,9,4,2,DOWN,5,1,0,4,10,2538799,4603702,,1,1,2,,6,,2,0,,2,L4CON,,0,0,16,0,0,0,0,0,,,,1,0,",
        "foo-farm,preprod-test,0,0,0,0,30,0,0,0,,0,,0,0,0,0,DOWN,5,1,0,0,1,5102839,5102839,,1,1,3,,0,,2,0,,0,L4CON,,0,0,0,0,0,0,0,0,,,,0,0,",
        "foo-farm,BACKEND,0,84,0,150,200,159082,38619996,3233457381,0,0,,19991,734,4,2,UP,10,1,0,,148,10893,300268,,1,1,0,,114853,,1,0,,144,,,,0,135843,2128,147,20955,9,,,,,21,11,",
        "foo-https-farm,FRONTEND,,,0,3,2000,6545,2675933,71871179,0,0,76,,,,,OPEN,,,,,,,,,1,2,0,,,,0,0,0,3,,,,0,5912,181,82,313,57,,0,3,6545,,,",
        "foo-https-farm,preprod-app,0,0,0,3,60,6219,2577996,71804141,,0,,1,30,3,0,UP,12,1,0,580,142,10893,257923,,1,2,1,,1948,,2,0,,2,L7OK,200,70,0,5912,181,11,29,0,0,,,,501,0,",
        "foo-https-farm,preprod-bg,0,0,0,0,30,0,0,0,,0,,0,0,0,0,DOWN,5,1,0,4,4,2538799,4603673,,1,2,2,,0,,2,0,,0,L4CON,,0,0,0,0,0,0,0,0,,,,0,0,",
        "foo-https-farm,preprod-test,0,0,0,0,30,0,0,0,,0,,0,0,0,0,DOWN,5,1,0,0,1,5102837,5102837,,1,2,3,,0,,2,0,,0,L4CON,,0,0,0,0,0,0,0,0,,,,0,0,",
        "foo-https-farm,BACKEND,0,0,0,3,200,6469,2675933,71871179,0,0,,254,30,3,0,UP,12,1,0,,142,10893,300288,,1,2,0,,1948,,1,0,,2,,,,0,5912,181,11,313,52,,,,,501,0,"]
      @info_422 = ["Name: HAProxy", "Version: 1.4.22", "Release_date: 2012/08/09", "Nbproc: 1", "Process_num: 1",
                   "Pid: 3803", "Uptime: 0d 2h46m58s", "Uptime_sec: 10018", "Memmax_MB: 0", "Ulimit-n: 536",
                   "Maxsock: 536", "Maxconn: 256", "Maxpipes: 0", "CurrConns: 1", "PipesUsed: 0", "PipesFree: 0",
                   "Tasks: 12", "Run_queue: 1", "node: haproxy1.company.com", "description:"]
    end



    describe 'multiple instances' do
      before(:each) do
        HAPSocket.any_instance.expects(:execute).times(3).returns(@stat_response)
      end

      # tests that we can create three instances given a array of sockets
      it 'can create 3 new instances via unique sockets' do
        sockets = ['/tmp/xxx1', '/tmp/xxx2', '/tmp/xxx3']
        proxies = Instance.create_instances(sockets)
        proxies.should be_instance_of Hash
        proxies.keys.length.should eq(3)
        proxies.values.length.should eq(3)
      end
    end

    describe "creation" do
      before(:each) do
        HAPSocket.any_instance.expects(:execute).once.returns(@stat_response)
        @instance = Instance.new("foo")
      end

      it "parses stats and lists backends" do
        @instance.backends.size.should == 2
        @instance.backends.should include "foo-farm"
        @instance.backends.should include "foo-https-farm"
      end

      it "parses stats and lists servers" do
        @instance.servers('foo-farm').size.should == 3
      end
      it "understands servers without backend are all servers" do
        @instance.servers.size.should == 6
        @instance.servers.should include "preprod-bg"
        @instance.servers.should include "preprod-test"
      end
    end

    describe "enables/disables servers" do

      before(:each) do
        HAPSocket.any_instance.expects(:execute).once.returns(@stat_response)
        @instance = Instance.new("foo")
      end

      it "enables a server" do
        HAPSocket.any_instance.expects(:execute).with('enable server foo-farm/preprod-bg')
        @instance.enable("preprod-bg", "foo-farm")
      end

      it "enables a all servers in multiple backends" do
        HAPSocket.any_instance.expects(:execute).with('enable server foo-farm/preprod-bg')
        HAPSocket.any_instance.expects(:execute).with('enable server foo-https-farm/preprod-bg')
        @instance.enable("preprod-bg")
      end

      it "disables a server" do
        HAPSocket.any_instance.expects(:execute).with('disable server foo-farm/preprod-bg')
        @instance.disable("preprod-bg", "foo-farm")
      end

      it "disables a server in all backends" do
        HAPSocket.any_instance.expects(:execute).with('disable server foo-farm/preprod-bg')
        HAPSocket.any_instance.expects(:execute).with('disable server foo-https-farm/preprod-bg')
        @instance.disable("preprod-bg")
      end
    end
    describe "weights" do
      before(:each) do
        HAPSocket.any_instance.expects(:execute).once.returns(@stat_response)
        @instance = Instance.new("foo")
      end

      it "gets current weight" do
        HAPSocket.any_instance.expects(:execute).with('get weight foo-farm/preprod-bg').returns(["10 (initial 12)"])
        weights = @instance.weights("preprod-bg","foo-farm" )
        weights[:current].should == 10
        weights[:initial].should == 12
      end

      it "sets weight if weight is specified" do
        HAPSocket.any_instance.expects(:execute).with('set weight foo-farm/preprod-bg 20')
        weights = @instance.weights "preprod-bg","foo-farm", 20
      end
    end
    describe "stats" do

      before(:each) do
        HAPSocket.any_instance.expects(:execute).once.returns(@stat_response)
        @instance = Instance.new("foo")
      end

      it "show for all servers" do
        HAPSocket.any_instance.expects(:execute).with('show stat -1 -1 -1').returns(@allstats)
        stats = @instance.stats
        stats.keys.size.should == 2
        stats.keys.should include "foo-farm"
        stats.keys.should include "foo-https-farm"
        stats["foo-farm"].keys.size.should == 5
        ["BACKEND", "FRONTEND", "preprod-app", "preprod-bg"].each do |item|
          stats["foo-farm"].keys.should include item
          stats["foo-https-farm"].keys.should include item
        end
        stats["foo-https-farm"]["preprod-app"]["status"].should == "UP"
        stats["foo-https-farm"]["preprod-app"]["weight"].should == "12"
        stats["foo-https-farm"]["preprod-bg"]["status"].should == "DOWN"
        stats["foo-https-farm"]["preprod-bg"]["weight"].should == "5"
      end
    end

    describe "info about haproxy" do

      before(:each) do
        HAPSocket.any_instance.expects(:execute).once.returns(@stat_response)
        @instance = Instance.new("foo")
      end

      it "has description/version and uptime" do
        HAPSocket.any_instance.expects(:execute).with("show info").returns(@info_response)
        info = @instance.info
        info["description"].should == 'Our awesome load balancer'
        info["Version"].should == '1.5-dev11'
        info["Uptime"].should == '58d 3h50m53s'
      end

      it "does not choke on values that do not exist" do
        HAPSocket.any_instance.expects(:execute).with("show info").returns(@info_422)
        info = @instance.info
        info["description"].should == ''
        info["Version"].should == '1.4.22'
        info["Uptime"].should == '0d 2h46m58s'
      end
    end
  end
end