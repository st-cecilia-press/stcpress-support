require 'erb'
class LilyGenerator
  attr_reader :template, :parts, :transposed, :verses
  def initialize(template: nil, parts:, transposed:, verses: )
    @template = get_template
    @parts = parts_structure(parts)
    @transposed = transposed 
    @verses = verses
  end
  def save(file)
    File.open(file, "w+") do|f|
      f.write(ScoreErbRenderer.new(parts: @parts, transposed: @transposed, template: @template, verses: @verses).render)
    end
  end
  def get_template
    #dummy parent method
    template
  end
  def parts_structure(num_parts)
    #dummy parent method
    num_parts
  end
  private

end

class ScoreErbRenderer
  include ERB::Util
  def initialize(parts:,verses:,transposed:,template:)
    @parts = parts
    @verses = verses
    @transposed = transposed
    @template = template
  end

  def render
    ERB.new(@template).result(binding)
  end
end
