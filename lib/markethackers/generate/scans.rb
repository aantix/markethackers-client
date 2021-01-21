require 'erb'

module Markethackers
  module Generate
    class Scans
      include Markethackers::Settings

      TEMPLATE_DIR = "lib/markethackers/templates/scans/"
      
      attr_accessor :name, :remote_script_template, :local_script_template

      def initialize(template_name, name)
        read_settings
        
        @name = name
        raise ArgumentError.new("Must provide a name for the scan.") if name.nil?
        raise ArgumentError.new("Must specify a template.") if template_name.nil?

        @remote_script_template = File.join(TEMPLATE_DIR, "remote", "#{template_name}.erb")
        @local_script_template  = File.join(TEMPLATE_DIR, "local", "#{template_name}.erb")
      end

      def generate
        scan_id      = generate_remote
        local_script = generate_local(scan_id)

        puts "Your Market Hackers scan has been created : #{url}/scans/#{scan_id}"
        puts "  Use this to look for next day, potentional stock candidates."
        puts
        puts "Your local scan script was created at : #{local_script}."
        puts "  Use this to take the candidates from your Market Hacker scan"
        puts "  and load those candidates into Interactive Brokers for possible trades."
        puts "  This is where you will control your market/limit/stop orders."
      end

      private
      def generate_remote
        client   = Markethackers::Client::Scan.new(name,
                     rendered(remote_script_template, linefeed: "<br/>"))
        scan_id  = client.create

        scan_id
      rescue StandardError => e
        puts "Problem creating the remote scan on Market Hackers."
        puts
        raise e
      end

      def generate_local(id)
        scan_id  = id
        title    = name.parameterize(separator: '_')

        local_script_path = "#{Dir.pwd}/#{title}.rb"
        File.write(local_script_path, rendered(local_script_template))
        local_script_path
      rescue StandardError => e
        puts "Problem generating the local script."
        puts
        raise e
      end

      def rendered(path, linefeed: "\n")
        renderer = ERB.new(File.read(path).gsub("\n", linefeed))
        renderer.result(binding)
      end
    end
  end
end