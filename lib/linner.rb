require_relative "linner/helper"
require_relative "linner/config"
require_relative "linner/wrapper"
require_relative "linner/template"
require_relative "linner/notifier"
require_relative "linner/compressor"

include Linner::Helper

module Linner
  extend self
  include Linner::Helper

  def config
    @config ||= Linner::Config.new("config.yml")
  end

  def perform
    Linner::Notifier.notify do
      config.files.each do |type|
        Thread.new do
          type["join"].to_h.each do |path, regex|
            file_path = File.join(root, config.public_folder, path)
            FileUtils.mkdir_p File.dirname(file_path)
            File.open file_path, "w+" do |f|
              matches = Dir.glob(File.join root, regex)
              order(matches, type["order"].to_h["before"].to_a , type["order"].to_h["after"].to_a)
              matches.each do |s|
                Linner::Template.new(s).render_to(f)
              end
            end
          end
        end.join #Thread
      end #Files
    end #Notify
  end #perform
end

Linner.perform
