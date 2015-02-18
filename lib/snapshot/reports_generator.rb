require 'erb'
require 'fastimage'

module Snapshot
  class ReportsGenerator
    def generate
      screens_path = SnapshotConfig.shared_instance.screenshots_path

      @data = {}
      
      Dir.chdir(screens_path) do
        Dir["*"].sort.each do |language_path|
          language = File.basename(language_path)
          Dir[File.join(language_path, '*')].sort.each do |screenshot|

            available_devices.each do |key_name, output_name|

              if File.basename(screenshot).include?key_name
                # This screenshot it from this device
                @data[language] ||= {}
                @data[language][output_name] ||= []

                @data[language][output_name] << screenshot
                break # to not include iPhone 6 and 6 Plus (name is contained in the other name)
              end
            end
          end
        end

        html_path = File.join(lib_path, "snapshot/page.html.erb")
        html = ERB.new(File.read(html_path)).result(binding) # http://www.rrn.dk/rubys-erb-templating-system

        export_path = "./screenshots.html"
        File.write(export_path, html)

        Helper.log.info "Successfully created HTML file with an overview of all the screenshots: '#{File.expand_path(export_path)}'".green
      end
    end

    private
      def lib_path
        if not Helper.is_test? and Gem::Specification::find_all_by_name('snapshot').any?
          return [Gem::Specification.find_by_name('snapshot').gem_dir, 'lib'].join('/')
        else
          return './lib'
        end
      end

      def available_devices
        # The order IS important, since those names are used to check for include?
        # and the iPhone 6 is inlucded in the iPhone 6 Plus
        {
          'iPhone6Plus' => "iPhone 6 Plus",
          'iPhone6' => "iPhone 6",
          'iPhone5' => "iPhone 5",
          'iPhone4' => "iPhone 4",
          'iOS-iPad' => "iPad"
        }
      end
  end
end