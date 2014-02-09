module Tabula
  ##
  # a "collection" of TextElements
  class TextChunk < ZoneEntity
    attr_accessor :font, :font_size, :text_elements, :width_of_space

    ##
    # initialize a new TextChunk from a TextElement
    def self.create_from_text_element(text_element)
      raise TypeError, "argument is not a TextElement" unless text_element.instance_of?(TextElement)
      tc = self.new(*text_element.tlwh)
      tc.text_elements = [text_element]
      return tc
    end

    #
    # group an iterable of TextChunk into a list of Line
    # def self.group_by_lines(text_chunks)
    #   lines = text_chunks.inject([]) do |memo, te|
    #     next memo if te.text =~ ONLY_SPACES_RE
    #     l = memo.find { |line| line.horizontal_overlap_ratio(te) >= 0.01 }
    #     if l.nil?
    #       l = Line.new
    #       memo << l
    #     end
    #     l << te
    #     memo
    #   end
    #   lines.map!(&:remove_sequential_spaces!)
    # end

    def self.group_by_lines(text_chunks)
      l = Line.new
      l << text_chunks.first

      lines = text_chunks[1..-1].inject([l]) do |memo, te|
        if memo.last.horizontal_overlap_ratio(te) < 0.01
          memo << Line.new
        end
        memo.last << te
        memo
      end

      lines.map!(&:remove_sequential_spaces!)
    end

    ##
    # returns a list of column boundaries (x axis)
    # +lines+ must be an array of lines sorted by their +top+ attribute
    def self.column_positions(lines)
      init = lines.first.text_elements.inject([]) { |memo, text_chunk|
        next memo if text_chunk.text =~ ONLY_SPACES_RE
        memo << Tabula::ZoneEntity.new(*text_chunk.tlwh)
        memo
      }

      regions = lines[1..-1]
        .inject(init) do |column_regions, line|

        line_text_elements = line.text_elements.clone

        column_regions.each do |cr|

          overlaps = line_text_elements
            .select { |te| te.text !~ ONLY_SPACES_RE && cr.horizontally_overlaps?(te) }

          overlaps.inject(cr) do |memo, te|
            cr.merge!(te)
          end

          line_text_elements = line_text_elements - overlaps
        end

        column_regions += line_text_elements.map { |te| Tabula::ZoneEntity.new(*te.tlwh) }
      end

      regions.map { |r| r.right.round(2) }.uniq
    end

    ##
    # add a TextElement to this TextChunk
    def <<(text_element)
      self.text_elements << text_element
      self.merge!(text_element)
    end

    def merge!(other)
      if other.instance_of?(TextChunk)
        if (self <=> other) < 0
          self.text_elements = self.text_elements + other.text_elements
        else
          self.text_elements = other.text_elements + self.text_elements
        end
      end
      super(other)
    end

    ##
    # split this TextChunk vertically
    # (in place, returns the remaining chunk)
    def split_vertically!(y)
      raise "Not Implemented"
    end

    def text
      self.text_elements.map(&:text).join
    end

    def inspect
      "#<TextChunk: #{self.top.round(2)},#{self.left.round(2)},#{self.bottom.round(2)},#{right.round(2)} '#{self.text}'>"
    end

    def to_h
      super.merge(:text => self.text)
    end
  end
end
