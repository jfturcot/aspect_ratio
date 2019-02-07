require 'bigdecimal'

module AspectRatio
  def self.resize(x, y, x_max = nil, y_max = nil, enlarge = true)
    x = BigDecimal(x)
    y = BigDecimal(y)

    if x_max && y_max
      return [x.to_i, y.to_i] if !enlarge && x <= x_max && y <= y_max

      # Maximum values of height and width given, aspect ratio preserved.
      if y > x
        return [(y_max * x / y).round, y_max]
      else
        return [x_max, (x_max * y / x).round]
      end
    elsif x_max
      return [x.to_i, y.to_i] if !enlarge && x <= x_max

      # Width given, height automagically selected to preserve aspect ratio.
      return [x_max, (x_max * y / x).round]
    else
      return [x.to_i, y.to_i] if !enlarge && y <= y_max

      # Height given, width automagically selected to preserve aspect ratio.
      return [(y_max * x / y).round, y_max]
    end
  end

  def self.crop(x, y, r)
    orient = r.split('!')[1]
    ratio  = r.split('!')[0].split(':').sort.map { |r| BigDecimal(r) }

    vertical = y > x
    rotate = y > x && orient == 'h' || x > y && orient == 'v'

    if (vertical || rotate) && !(vertical && rotate)
      x = x + y
      y = x - y
      x = x - y
    end

    xʹ = x
    yʹ = x * (ratio[1] / ratio[0])

    if (yʹ > y) || rotate && (yʹ > x)
      yʹ = y
      xʹ = y * (ratio[1] / ratio[0])

      if xʹ > x
        xʹ = x
        yʹ = x * (ratio[0] / ratio[1])
      end
    end

    _x = ((x - xʹ) / 2).to_f.floor
    _y = ((y - yʹ) / 2).to_f.floor

    if (vertical || rotate) && !(vertical && rotate)
      [
        _y,         # crop top left x
        _x,         # crop top left y
        y - _y * 2, # crop width
        x - _x * 2  # crop height
      ]
    else
      [
        _x.to_f,    # crop top left x
        _y,         # crop top left y
        x - _x * 2, # crop width
        y - _y * 2  # crop height
      ]
    end
  end
end
