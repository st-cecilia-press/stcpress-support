require_relative './lily_generator'
class VocalTemplateGenerator < LilyGenerator
  def get_template
    File.read(File.join(__dir__, 'vocal_template.ly.erb')) 
  end
  def parts_structure(num_parts)
    [
      {number: 'One', clef: 'treble', name: 'cantus'},
      {number: 'Two', clef: 'treble', name: 'altus'},
      {number: 'Three', clef: 'G_8', name: 'tenor'},
      {number: 'Four', clef: 'bass', name: 'bassus'},
      {number: 'Five', clef: 'bass', name: 'quintus'},
      {number: 'Six', clef: 'treble', name: 'sextus'},
      {number: 'Seven', clef: 'treble', name: 'septus'},
      {number: 'Eight', clef: 'treble', name: 'octus'}
    ][0..num_parts-1]
  end
end
