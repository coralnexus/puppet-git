
module CORL
module Template
class Gitconfig < CORL.plugin_class(:template)
  
  #-----------------------------------------------------------------------------
  # Renderers  
   
  def render_processed(input)
    output = ''
        
    case input      
    when Hash
      input.each do |type, data|
        output << render_section(type, data)
      end
    end              
    return output     
  end
  
  #-----------------------------------------------------------------------------
    
  def render_section(type, input)
    output = ''
    
    if input.is_a?(Hash)
      components = type.split(/\s*,\s*/)
    
      if components.size == 2
        components[1] = '"' + components[1].gsub(/\"/, '\"') + '"'
      end
      type = components.join(' ')
    
      output << "[#{type}]\n"  
      input.each do |name, value|
        value = render_value(value)
        output << "  #{name} = #{value}\n"
      end
    end  
    return output  
  end
  
  #---
  
  def render_value(value)
    if Util::Data.true?(value) || Util::Data.false?(value) || 
      ! value.is_a?(String) || value.match(/^\-?[\d\.]+$/)
      return value
    else
      return '"' + value.gsub(/\"/, '\"') + '"'
    end
  end  
end
end
end