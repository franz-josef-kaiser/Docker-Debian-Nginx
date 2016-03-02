require "serverspec"
require "docker-api"

describe "Dockerfile" do
	before( :all ) do
		print "Running Tests for Docker\n"
		print " ---> Docker Version " + Docker.version["Version"] + "\n\n"

		@image = Docker::Image.build_from_dir( "." )

		set :os, family: :debian, :release => '8'
		set :backend, :docker
		set :docker_image, @image.id

		@container = Docker::Container.create(
			'Image' => @image.id,
			'Cmd'   => [ "nginx", "-g", "deamon off;" ]
		)
		@container.start

		print " ---> Details\n"
		print "  OS: " + host_inventory["platform"]
			print " " + host_inventory["platform_version"] + "\n"
		print "  Docker Container: " + host_inventory["hostname"] + "\n"
		print "  Memory: " + host_inventory["memory"]["total"] + "\n\n"

		print " ---> Running tests\n"
	end

	after( :all ) do
		print "\n\n ---> Cleaning up. Removing container."
		@container.stop
		@container.kill
		@container.delete( :force => true )
		@image.remove( :force => true )
	end

	it "Image should exist" do
		expect( @image ).to_not be_nil
	end

	it "Installs the right OS" do
		expect( command( "lsb_release -a" ).stdout ).to include( "Debian" )
		expect( command( "lsb_release -a" ).stdout ).to include( "jessie" )
	end

	it "Installs the right OS Version" do
		expect( command( "cat /etc/debian_version" ).stdout ).to include( "8" )
	end

	it "Installs 'lsb-release' package" do
		expect( package( "lsb-release" ) ).to be_installed
	end

	it "Installs 'ca-certificates' package" do
		expect( package( "ca-certificates" ) ).to be_installed
	end

	it "Installs 'gettext-base' package" do
		expect( package( "gettext-base" ) ).to be_installed
	end

	it "Installs Nginx" do
		expect( package( "nginx" ) ).to be_installed
	end

	it "Nginx service should be enabled and running" do
		expect( service( "nginx" ) ).to be_enabled
		expect( service( "nginx" ) ).to be_running
	end

	it "Nginx process should be running" do
		expect( process( "nginx" ) ).to be_running
	end

	it "Has a logs directory and routes stdout to log files" do
		expect( file( "/etc/nginx/logs" ) ).to exist
		expect( file( "/etc/nginx/logs" ) ).to be_directory
		expect( file( "/var/log/nginx/access.log" ) ).to be_symlink
		expect( file( "/var/log/nginx/error.log" ) ).to be_symlink
	end

	it "Has a cache directory" do
		expect( file( "/var/cache/nginx/temp" ) ).to exist
		expect( file( "/var/cache/nginx/temp" ) ).to be_directory
	end

	it "Has a sites config and sites enabled directory" do
		expect( file( "/etc/nginx/sites-available" ) ).to exist
		expect( file( "/etc/nginx/sites-available" ) ).to be_directory
		expect( file( "/etc/nginx/sites-enabled" ) ).to be_symlink
	end
end
