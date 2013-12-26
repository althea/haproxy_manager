require 'spec_helper'

module HAProxyManager
  describe Server do
    before(:all) do
      @stat_response = ["# pxname,svname,qcur,qmax,scur,smax,slim,stot,bin,bout,dreq,dresp,ereq,econ,eresp,wretr,wredis,status,weight,act,bck,chkfail,chkdown,lastchg,downtime,qlimit,pid,iid,sid,throttle,lbtot,tracked,type,rate,rate_lim,rate_max,check_status,check_code,check_duration,hrsp_1xx,hrsp_2xx,hrsp_3xx,hrsp_4xx,hrsp_5xx,hrsp_other,hanafail,req_rate,req_rate_max,req_tot,cli_abrt,srv_abrt,",
                        "foo-farm,preprod-app,0,9,0,60,60,137789,34510620,3221358490,,0,,3,720,0,0,UP,12,1,0,562,143,45394,255790,,1,1,1,,113890,,2,0,,88,L7OK,200,20,0,134660,2028,147,230,0,0,,,,20,6,",
                        "foo-farm,preprod-bg,0,0,0,3,30,31,14333,380028,,0,,0,9,4,2,DOWN,5,1,0,4,10,2453494,4518397,,1,1,2,,6,,2,0,,2,L4CON,,0,0,16,0,0,0,0,0,,,,1,0,",
                        "foo-farm,preprod-test,0,0,0,0,30,0,0,0,,0,,0,0,0,0,MAINT,5,1,0,0,1,5017534,5017534,,1,1,3,,0,,2,0,,0,L4CON,,0,0,0,0,0,0,0,0,,,,0,0,",
                        "foo-https-farm,preprod-app,0,0,0,3,60,6219,2577996,71804141,,0,,1,30,3,0,UP,12,1,0,559,137,45394,255774,,1,2,1,,1948,,2,0,,2,L7OK,200,109,0,5912,181,11,29,0,0,,,,501,0,",
                        "foo-https-farm,preprod-bg,0,0,0,0,30,0,0,0,,0,,0,0,0,0,DOWN,5,1,0,4,4,2453494,4518368,,1,2,2,,0,,2,0,,0,L4CON,,0,0,0,0,0,0,0,0,,,,0,0,",
                        "foo-https-farm,preprod-test,0,0,0,0,30,0,0,0,,0,,0,0,0,0,DOWN,5,1,0,0,1,5017532,5017532,,1,2,3,,0,,2,0,,0,L4CON,,0,0,0,0,0,0,0,0,,,,0,0,"]
      @info_response = ["Name: HAProxy", "Version: 1.5-dev11", "Release_date: 2012/06/04", "Nbproc: 1", "Process_num: 1", "Pid: 4084", "Uptime: 58d 3h50m53s", "Uptime_sec: 5025053", "Memmax_MB: 0", "Ulimit-n: 40029", "Maxsock: 40029", "Maxconn: 20000", "Hard_maxconn: 20000", "Maxpipes: 0", "CurrConns: 0", "PipesUsed: 0", "PipesFree: 0", "ConnRate: 0", "ConnRateLimit: 0", "MaxConnRate: 69", "Tasks: 10", "Run_queue: 1", "Idle_pct: 100", "node: some machine on ec3", "description: Our awesome load balancer"]
      @allstats = ["# pxname,svname,qcur,qmax,scur,smax,slim,stot,bin,bout,dreq,dresp,ereq,econ,eresp,wretr,wredis,status,weight,act,bck,chkfail,chkdown,lastchg,downtime,qlimit,pid,iid,sid,throttle,lbtot,tracked,type,rate,rate_lim,rate_max,check_status,check_code,check_duration,hrsp_1xx,hrsp_2xx,hrsp_3xx,hrsp_4xx,hrsp_5xx,hrsp_other,hanafail,req_rate,req_rate_max,req_tot,cli_abrt,srv_abrt,",
                   "foo-farm,FRONTEND,,,0,150,2000,165893,38619996,3233457381,0,0,6504,,,,,OPEN,,,,,,,,,1,1,0,,,,0,0,0,69,,,,0,136147,2128,6654,20955,9,,0,144,165893,,,",
                   "foo-farm,preprod-app,0,9,0,60,60,139066,34839081,3222850212,,0,,3,725,0,0,UP,10,1,0,583,148,10893,257935,,1,1,1,,114847,,2,0,,88,L7OK,200,150,0,135827,2128,147,230,0,0,,,,20,11,",
                   "foo-farm,preprod-bg,0,0,0,3,30,31,14333,380028,,0,,0,9,4,2,DOWN,5,1,0,4,10,2538799,4603702,,1,1,2,,6,,2,0,,2,L4CON,,0,0,16,0,0,0,0,0,,,,1,0,",
                   "foo-farm,preprod-test,0,0,0,0,30,0,0,0,,0,,0,0,0,0,MAINT,5,1,0,0,1,5102839,5102839,,1,1,3,,0,,2,0,,0,L4CON,,0,0,0,0,0,0,0,0,,,,0,0,",
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

    before :each do
      HAProxyManager::HAPSocket.any_instance.stubs(:execute).returns(@allstats)

      instance = HAProxyManager::Instance.new("foo")
      @print_response = Proc.new {|response| puts response}
      @backend = instance.backend_instances['foo-farm']
      @server = @backend.servers['preprod-app']
    end

    it 'should return json listing' do
      expect{@server.stats_to_json}.to_not raise_error
    end

    it 'should create a server object' do
      @server.should be_instance_of HAProxyManager::Server
    end

    it 'should have list of backends' do
       @server.backends.should be_instance_of(Array)
    end

    it 'should return true if server is part of backend' do
       @server.has_backend?('foo-farm').should be_true
    end

    it 'server should be in multiple backends' do
      @server.backends.length.should eq(2)
    end

    it 'should be in backends foo-farm and foo-https-farm' do
      @server.backends.should include('foo-farm')
      @server.backends.should include('foo-https-farm')
    end

    it 'should disable itself from all backends' do
      HAPSocket.any_instance.expects(:execute).with('disable server foo-farm/preprod-app')
      HAPSocket.any_instance.expects(:execute).with('disable server foo-https-farm/preprod-app')
      @server.disable
    end

    it 'should enable itself from all backends' do
      HAPSocket.any_instance.expects(:execute).with('enable server foo-farm/preprod-app')
      HAPSocket.any_instance.expects(:execute).with('enable server foo-https-farm/preprod-app')
      @server.enable
    end

    it 'should disable itself from foo-farm backend' do
      HAPSocket.any_instance.expects(:execute).with('disable server foo-farm/preprod-app')
      @server.disable('foo-farm')
    end

    it 'should enable itself from foo-farm backend' do
      HAPSocket.any_instance.expects(:execute).with('enable server foo-farm/preprod-app')
      @server.enable('foo-farm')
    end

    it 'should disable itself from foo-farm backend' do
      HAPSocket.any_instance.expects(:execute).times(0).with('disable server foo-farm/preprod-app')
      @server.disable('foo-farm1')
    end

    it 'should enable itself from foo-farm backend' do
      HAPSocket.any_instance.expects(:execute).times(0).with('enable server foo-farm/preprod-app')
      @server.enable('foo-farm1')
    end
    it 'should raise error when no backend is specified' do
      expect{@server.status}.to raise_exception
    end

    it 'should return UP when a backend is specified' do
      @server.status('foo-farm').should eq('UP')
    end

    it 'should return MAINT when a backend is specified' do
      maintserver = @backend.servers['preprod-test']
      maintserver.status('foo-farm').should eq('MAINT')
    end

    it 'should return true when the server is under maint mode' do
      maintserver = @backend.servers['preprod-test']
      maintserver.maint?('foo-farm').should be_true
    end

    it 'should return true when up when a backend is provided' do
      @server.up?('foo-farm').should be_true
    end

    it 'should return false when down and a backend is provided' do
      @server.down?('foo-farm').should be_false
    end
    it 'should return the current weight of the server for the specific backend' do
      @server.weight('foo-farm').should eq([10])
    end

    it 'should return the current weight of the server for the specific backend' do
      @server.weight.should eq([10, 12])
    end

    it 'should set the weight of the server for the specific backend as a fixnum' do
      HAPSocket.any_instance.expects(:execute).times(1).with('set weight foo-farm/preprod-app 20')
      @server.set_weight(20, 'foo-farm')
    end

    it 'should set the weight of the server for all backends as a fixnum' do
      HAPSocket.any_instance.expects(:execute).times(1).with('set weight foo-farm/preprod-app 20')
      HAPSocket.any_instance.expects(:execute).times(1).with('set weight foo-https-farm/preprod-app 20')
      @server.set_weight(20)
    end

    it 'should set the weight of the server for the specific backend as a string' do
      HAPSocket.any_instance.expects(:execute).times(1).with('set weight foo-farm/preprod-app 20')
      @server.set_weight('20', 'foo-farm')
    end

    it 'should set the weight of the server for all backends as a string' do
      HAPSocket.any_instance.expects(:execute).times(1).with('set weight foo-farm/preprod-app 20')
      HAPSocket.any_instance.expects(:execute).times(1).with('set weight foo-https-farm/preprod-app 20')
      @server.set_weight('20')
    end

    it 'should return an array of stat names' do
      @server.stat_names.should be_instance_of(Array)
      @server.stat_names.should include('pxname', 'status', 'svname')
    end

    it 'method missing should return method not found if method is not a stat name' do
      expect{ @server.foo }.to raise_error(NoMethodError)
    end

    it 'method missing should return a hash of items with the total' do
      hash = @server.send('bin')
      hash.has_key?('total').should be_true
      hash['total'].should > 0
    end

    it 'method missing should return for every item in stat_names' do
      @server.stat_names.each do |name|
        next if name == 'status'
        hash = @server.send(name)
        hash.should_not be_nil
      end
    end

    it 'method missing should not error out if stat is a non integer value' do
        @server.send('pxname').should eq({"foo-farm/pxname"=>"foo-farm", "foo-https-farm/pxname"=>"foo-https-farm", "total"=>0})
    end

    it 'method missing should be able to convert strings to integers easily' do
        @server.send('bin').should eq({"foo-farm/bin"=>"34839081", "foo-https-farm/bin"=>"2577996", "total"=>37417077})
    end



  end

end