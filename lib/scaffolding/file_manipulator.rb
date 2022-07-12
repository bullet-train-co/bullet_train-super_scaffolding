require "scaffolding/block_manipulator"

# TODO: If we move this and the BlockManipulator into their own gems,
# we won't need to preface each call with `Scaffolding::`
module Scaffolding::FileManipulator
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
end
