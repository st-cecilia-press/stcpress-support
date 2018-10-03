require_relative './lily_generator'
class ScoreGenerator < LilyGenerator
  def save(file)
    File.open(file, "w+") do|f|
      f.write(renderer_factory.render)
      f.write(renderer_factory(transposed: true).render) if @transposed
    end
  end
  def get_template
    File.read(File.join(__dir__, 'score.ly.erb')) 
  end
  def parts_structure(number_of_parts) 
    ['One','Two','Three','Four','Five','Six','Seven','Eight'][0..number_of_parts-1]
  end
  private
  def renderer_factory(transposed: false)
     ScoreErbRenderer.new(template: @template, parts: @parts, verses: @verses, transposed: transposed)
  end

end
