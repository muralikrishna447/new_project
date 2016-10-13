module Utils
  def Utils.spelunk(obj, keys)
    value = obj
    keys.each_with_index{|k, i|
      value = value[k]
      if value.class != Hash and value.class != Array and i != (keys.length - 1)
        value = nil
        break
      end
    }
    return value
  end
end
