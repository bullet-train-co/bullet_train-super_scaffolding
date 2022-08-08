require "scaffolding/file_manipulator"

module Scaffolding::BlockManipulator
  #
  # Wrap a block of ruby code with another block on the outside.
  #
  # @param [String] `starting` A string to search for at the start of the block. Eg "<%= updates_for context, collection do"
  # @param [Array] `with` An array with two String elements. The text that should wrap the block. Eg ["<%= action_model_select_controller do %>", "<% end %>"]
  #
  def self.wrap_block(starting:, with:, lines:)
    with[0] += "\n" unless with[0].match?(/\n$/)
    with[1] += "\n" unless with[1].match?(/\n$/)
    starting_line = find_block_start(starting_from: starting, lines: lines)
    end_line = find_block_end(starting_from: starting_line, lines: lines)

    final = []
    block_indent = ""
    spacer = "  "
    lines.each_with_index do |line, index|
      line += "\n" unless line.match?(/\n$/)
      if index < starting_line
        final << line
      elsif index == starting_line
        block_indent = line.match(/^\s*/).to_s
        final << block_indent + with[0]
        final << (line.blank? ? "\n" : "#{spacer}#{line}")
      elsif index > starting_line && index < end_line
        final << (line.blank? ? "\n" : "#{spacer}#{line}")
      elsif index == end_line
        final << (line.blank? ? "\n" : "#{spacer}#{line}")
        final << block_indent + with[1]
      else
        final << line
      end
    end

    lines = final
    unless lines.last.match?(/\n$/)
      lines.last = "#{lines.last}\n"
    end
    lines
  end

  def self.insert(content, within: nil, after: nil, before: nil, after_block: nil, append: false, lines:)
    # Search for before like we do after, we'll just inject before it.
    after ||= before

    # If within is given, find the start and end lines of the block
    content += "\n" unless content.match?(/\n$/)
    start_line = 0
    end_line = lines.count - 1
    if within.present?
      start_line = find_block_start(starting_from: within, lines: lines)
      end_line = find_block_end(starting_from: start_line, lines: lines)
      # start_line += 1 # ensure we actually insert the content _within_ the given block
      # end_line += 1 if end_line == start_line
    end
    if after_block.present?
      block_start = find_block_start(starting_from: after_block, lines: lines)
      block_end = find_block_end(starting_from: block_start, lines: lines)
      start_line = block_end
      end_line = lines.count
    end
    index = start_line
    match = false
    while index < end_line && !match
      line = lines[index]
      if after.nil? || line.match?(after)
        unless append
          match = true
          # We adjust the injection point if we really wanted to insert before.
          lines = insert_line(content, index - (before ? 1 : 0), lines)
        end
      end
      index += 1
    end

    return lines if match

    # Match should always be false here.
    if append && !match
      lines = insert_line(content, index - 1, lines)
    end
    lines
  end

  def self.insert_line(content, insert_at_index, lines)
    content += "\n" unless content.match?(/\n$/)
    final = []
    lines.each_with_index do |line, index|
      indent = line.match(/^\s*/).to_s
      final << line
      if index == insert_at_index
        final << indent + content
      end
    end
    final
  end

  def self.insert_block(block_content, after_block:, lines:)
    block_start = find_block_start(starting_from: after_block, lines: lines)
    block_end = find_block_end(starting_from: block_start, lines: lines)
    lines = insert_line(block_content[0], block_end, lines)
    lines = insert_line(block_content[1], block_end + 1, lines)
  end

  def find_block_parent(starting_line_number, lines)
    return nil unless indentation_of(starting_line_number, lines)
    cursor = starting_line_number
    while cursor >= 0
      unless lines[cursor].match?(/^#{indentation_of(starting_line_number, lines)}/) || !lines[cursor].present?
        return cursor
      end
      cursor -= 1
    end
    nil
  end

  def self.find_block_start(starting_from:, lines:)
    matcher = Regexp.escape(starting_from)
    starting_line = 0

    lines.each_with_index do |line, index|
      if line.match?(matcher)
        starting_line = index
        break
      end
    end
    starting_line
  end

  def self.find_block_end(starting_from:, lines:)
    # This loop was previously in the RoutesFileManipulator.
    lines.each_with_index do |line, line_number|
      next unless line_number > starting_from
      if /^#{indentation_of(starting_from, lines)}end\s+/.match?(line)
        return line_number
      end
    end

    depth = 0
    current_line = starting_from
    lines[starting_from..lines.count].each_with_index do |line, index|
      current_line = starting_from + index
      depth += 1 if line.match?(/\s*<%.+ do .*%>/)
      depth += 1 if line.match?(/\s*<% if .*%>/)
      depth += 1 if line.match?(/\s*<% unless .*%>/)
      depth -= 1 if line.match?(/\s*<%.* end .*%>/)
      break current_line if depth == 0
    end
    current_line
  end

  def self.indentation_of(line_number, lines)
    lines[line_number].match(/^( +)/)[1]
  rescue
    nil
  end
end
