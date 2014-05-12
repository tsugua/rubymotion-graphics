# MacRuby Graphics is a graphics library providing a simple object-oriented
# interface into the power of Mac OS X's Core Graphics and Core Image drawing libraries.
# With a few lines of easy-to-read code, you can write scripts to draw simple or complex
# shapes, lines, and patterns, process and filter images, create abstract art or visualize
# scientific data, and much more.
#
# Inspiration for this project was derived from Processing and NodeBox.  These excellent
# graphics programming environments are more full-featured than RCG, but they are implemented
# in Java and Python, respectively.  RCG was created to offer similar functionality using
# the Ruby programming language.
#
# Author::    James Reynolds  (mailto:drtoast@drtoast.com)
# Copyright:: Copyright (c) 2008 James Reynolds
# License::   Distributes under the same terms as Ruby

module RMGraphics

  # draw a smooth gradient between any number of key colors
  class Gradient

    attr_reader :gradient, :drawpre, :drawpost

    # create a new gradient from black to white
    def initialize(*colors)
      @colorspace = CGColorSpaceCreateDeviceRGB()
      colors      = colors[0] if colors[0].class == Array
      set(colors)
      pre(true)
      post(true)
      self
    end

    # create a gradient that evenly distributes the given colors
    def set(colors)
      colors ||= [Color.black, Color.white]
      cgcolors  = []
      locations = []
      increment = 1.0 / (colors.size - 1).to_f
      i         = 0
      colors.each do |c|
        # rgba = Pointer.new('d',4)
        # rgba[0] = [c.r.to_f, c.g.to_f, c.b.to_f, c.a.to_f]
        # cgcolor = CGColorCreate(@colorspace, rgba )
        cgcolor = NSColor.colorWithCalibratedRed(c.r, green: c.g, blue: c.b, alpha: c.a).CGColor

        cgcolors.push(cgcolor)
        location = i * increment
        locations.push(location)
        i = i + 1
      end
      # p locations
      locations_ptr = Pointer.new('d', locations.length)
      # locations_ptr[1] = locations
      locations.each { |e|
          locations_ptr[locations.index(e)] = locations[e]
        }
      @gradient = CGGradientCreateWithColors(@colorspace, cgcolors, locations_ptr)
    end

    # extend gradient before start location? (true/false)
    def pre(tf=nil)
      @drawpre = (tf ? KCGGradientDrawsBeforeStartLocation : 0) unless tf.nil?
      @drawpre
    end

    # extend gradient after end location? (true/false)
    def post(tf=nil)
      @drawpost = (tf ? KCGGradientDrawsAfterEndLocation : 0) unless tf.nil?
      @drawpost
    end

  end
end
