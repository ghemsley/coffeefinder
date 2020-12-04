module Coffeefinder
  class FileIO
    attr_accessor :path, :hash

    def initialize(path = FILE_PATH)
      self.hash = {}
      self.path = path
    end

    def read_json(path = self.path)
      self.path = path
      self.hash = JSON.parse(File.read(self.path)) if File.exist?(self.path)
      hash
    end

    def write_json(path = self.path)
      File.open(path, 'w') do |file|
        file.write(JSON.pretty_generate(hash))
      end
    end

    def delete(path = self.path)
      File.delete(path) if File.exist?(path)
    end
  end
end
