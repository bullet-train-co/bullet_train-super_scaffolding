require "scaffolding/block_manipulator"

# TODO: If we move this and the BlockManipulator into their own gems,
# we can probably call these methods with something shorter without `Scaffolding::`.
module Scaffolding::FileManipulator
  # TODO: The block_manipulator shouldn't be an instance variable.
  def self.find(lines, needle, within = nil, block_manipulator)
    lines_within(lines, within, block_manipulator).each_with_index do |line, line_number|
      return (within + (within ? 1 : 0) + line_number) if line.match?(needle)
    end
    nil
  end

  # TODO: The block_manipulator shouldn't be an instance variable.
  def self.lines_within(lines, within, block_manipulator)
    return lines unless within
    lines[(within + 1)..(block_manipulator.find_block_end(starting_from: within, lines: lines) + 1)]
  end

  def self.replace_line_in_file(file, content, in_place_of)
    target_file_content = File.read(file)

    if target_file_content.include?(content)
      puts "No need to update '#{file}'. It already has '#{content}'."
    else
      puts "Updating '#{file}'."
      target_file_content.gsub!(in_place_of, content)
      File.write(file, target_file_content)
    end
  end

  # Pass in an array where this content should be inserted within the yml file.
  # For example, to add content to admin.models pass in [:admin, :models]
  def self.add_line_to_yml_file(file, content, location_array)
    # First check that the given location array actually exists in the yml file:
    yml = YAML.safe_load(File.read(file))
    location_array.map!(&:to_s)

    # TODO: Raise an error if we're returning nil.
    return nil if yml.dig(*location_array).nil?

    content += "\n" unless content[-1] == "\n"
    # Find the location in the file where the location_array is
    lines = File.readlines(file)
    current_needle = location_array.shift.to_s
    current_space = ""
    insert_after = 1
    lines.each_with_index do |line, index|
      break if current_needle.nil?
      if line.strip == current_needle + ":"
        current_needle = location_array.shift.to_s
        insert_after = index
        current_space = line.match(/\s+/).to_s
      end
    end
    new_lines = []
    current_space += "  "
    lines.each_with_index do |line, index|
      new_lines << line
      new_lines << current_space + content if index == insert_after
    end
    File.write(file, new_lines.join)
  end

  def self.write(file_name, lines)
    puts "Updating '#{file_name}'."
    File.open(file_name, "w+") do |file|
      file.puts(lines.join.strip + "\n")
    end
  end
end
