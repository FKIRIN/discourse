
def run_or_fail(command)
  pid = Process.spawn(command)
  Process.wait(pid)
  $?.exitstatus == 0
end

desc 'Run all tests (JS and code in a standalone environment)'
task 'docker:test' do
  begin

    puts "Cleaning up old test tmp data in tmp/test_data"
    `rm -fr tmp/test_data && mkdir -p tmp/test_data/redis && mkdir tmp/test_data/pg`

    puts "Starting background redis"
    @redis_pid = Process.spawn('redis-server --dir tmp/test_data/redis')

    @postgres_bin = "/usr/lib/postgresql/9.5/bin/"
    `#{@postgres_bin}initdb -D tmp/test_data/pg`

    # speed up db, never do this in production mmmmk
    `echo fsync = off >> tmp/test_data/pg/postgresql.conf`
    `echo full_page_writes = off >> tmp/test_data/pg/postgresql.conf`
    `echo shared_buffers = 500MB >> tmp/test_data/pg/postgresql.conf`

    puts "Starting postgres"
    @pg_pid = Process.spawn("#{@postgres_bin}postmaster -D tmp/test_data/pg")


    ENV["RAILS_ENV"] = "test"

    @good = run_or_fail("bundle exec rake db:create db:migrate")

    if ENV["INSTALL_OFFICIAL_PLUGINS"]
      @good &&= run_or_fail("bundle exec rake plugin:install_all_official")
    end

    unless ENV["JS_ONLY"]

      unless ENV["SKIP_CORE"]
        @good &&= run_or_fail("bundle exec rspec")
      end

      if ENV["LOAD_PLUGINS"]
        @good &&= run_or_fail("bundle exec rake plugin:spec")
      end
    end
    unless ENV["RUBY_ONLY"]
      @good &&= run_or_fail("eslint app/assets/javascripts")
      @good &&= run_or_fail("eslint --ext .es6 app/assets/javascripts")
      @good &&= run_or_fail("eslint --ext .es6 test/javascripts")
      @good &&= run_or_fail("eslint test/javascripts")
      @good &&= run_or_fail("bundle exec rake qunit:test['600000']")
    end

  ensure
    puts "Terminating"

    Process.kill("TERM", @redis_pid)
    Process.kill("TERM", @pg_pid)
    Process.wait @redis_pid
    Process.wait @pg_pid
  end

  if !@good
    exit 1
  end

end
