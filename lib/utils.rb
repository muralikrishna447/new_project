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

  # Uses the Efraimidis and Spirakis algorithm for weighted random sampling without replacement in a single pass.
  # (http://utopia.duth.gr/~pefraimi/research/data/2007EncOfAlg.pdf)
  # If this is more generally useful it could become a utility. Not optimized for large populations.
  def Utils.weighted_random_sample(items, weight_field, limit)
    return items if items.empty?

    # Build an array of objects mapping weights to items, and get total weight
    weighted_items = []
    total_weight = 0
    items.each do |item|
      weight = [item[weight_field], 1].max
      total_weight += weight
      weighted_items.push({item: item, weight: weight})
    end
    # Each item gets its own random value, raised to the inverse exponent of its weight
    weighted_items.each { |wi| wi[:weight] = rand() ** (total_weight / wi[:weight])}

    # Sort by the random results and select the first N
    return weighted_items.sort_by { |wi| -wi[:weight] }[0...limit].map { |wi| wi[:item]}
  end
end
