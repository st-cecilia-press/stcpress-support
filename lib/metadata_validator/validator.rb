require 'yaml'
class Validator
  attr_reader :books_yaml_path, :manuscripts_yaml_path
  def initialize(books_yaml: File.join(__dir__, 'books.yaml'), manuscripts_yaml: File.join(__dir__, 'manuscripts.yaml'))
    @books_yaml_path = books_yaml
    @manuscripts_yaml_path = manuscripts_yaml
    @books_yaml = YAML.load_file(@books_yaml_path)
    @manuscripts_yaml = YAML.load_file(@manuscripts_yaml_path)
  end
end
