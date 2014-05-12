HERE = File.expand_path(File.dirname(__FILE__))

class ColorSamplerCustomView < NSView

  def flip_order(ord)
    ord == 'ltr' ? 'rtl' : 'ltr'
  end

  def calculate_position(x, y, order, rect, offset=20)
    @width ||= CGRectGetWidth(rect)
    if (x + offset > @width) || ((x - offset) == -20 && y != 0 && order == 'rtl')
      order = flip_order(order)
      y += offset
      new_row = true
    end
    unless x == 0 && new_row
      x = order == 'ltr' ?  x + offset : x - offset
    end
    [x, y, order]
  end

  def drawRect(rect)
    dimensions = [CGRectGetWidth(rect), CGRectGetHeight(rect)]
    @canvas = RMGraphics::Canvas.for_current_context(:size => dimensions)
      @canvas.background(RMGraphics::Color.gray.lighten(0.4))
      # load image and grab colors
      img = RMGraphics::Image.new(File.join(HERE, 'images', '1984.jpg')).saturation(1.9)

      # drawing the photo
      img_x = 100
      # y = height - resized img height - margin
      img_y = dimensions.last - 200 - 20
      @canvas.draw(img.resize(200, 200), img_x, img_y)

      # drawing the text
      @canvas.text("Color sampling from jpg", 100, img_y - 30)

      colors = img.colors(500)
      sample = RMGraphics::Path.new.rect
      x, y = -20, 0
      order = 'ltr'

      # sorting colors isn't quite easy
      # we are using spherical coordinates and multipass sorting
      theta_sorter = lambda{|cs, window| cs.each_slice(window).map{|s| s.sort_by {|c| c.spherical_coordinates.first} }.flatten}
      psi_sorter   = lambda{|cs, window| cs.each_slice(window).map{|s| s.sort_by {|c| c.spherical_coordinates.last} }.flatten}
      # sort on psi
      first_sort  = colors.sort_by{|c2| c2.spherical_coordinates.last }
      second_sort = theta_sorter.call(first_sort, 25)
      # third_sort  = theta_sorter.call(first_sort, 15) #psi_sorter.call(first_sort, 35)
      second_sort.reverse.each do |color|
        # skip of the color is too white or too black
        next if color.white? || color.brightness < 0.2
        x, y, order = calculate_position(x, y, order, rect)
        @canvas.push
        sample.fill(color)
        @canvas.draw(sample, x, y)
        @canvas.pop
      end

  end

end
