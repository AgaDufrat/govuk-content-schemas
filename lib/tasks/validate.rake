require "json-schema"

def base_path(example_file)
  JSON.parse(File.read(example_file))["base_path"]
end

def validate_schemas(schema_file_list)
  validation_errors = []
  schema_file_list.each do |schema|
    begin
      JSON::Validator.fully_validate(schema, {}, validate_schema: true)
    rescue JSON::Schema::ValidationError => e
      validation_errors << "#{schema}: #{e.message}"
    end
  end
  abort "\nThe following schemas aren't valid:\n" + validation_errors.join("\n") if validation_errors.any?
end

desc 'Validate that generated schemas are valid schemas'
task :validate_dist_schemas do
  print "Validating generated schemas... "
  validate_schemas(Rake::FileList.new("dist/formats/**/*.json"))
  puts "✔︎"
end

desc 'Validate examples against generated schemas'
task :validate_examples do
  print "Validating examples: "

  Dir.glob("examples/**/*.json").each do |example_path|
    example = File.read(example_path)
    _, schema_name, type, example_filename = example_path.split('/')
    schema_filename = example_filename.end_with?('_links.json') ? 'links.json' : 'schema.json'
    schema = File.read("dist/formats/#{schema_name}/#{type}/#{schema_filename}")

    begin
      JSON::Validator.validate!(schema, example)
      print "."
    rescue JSON::Schema::ValidationError => e
      abort "\n Error validating example #{example_path}: #{e.message}"
    end
  end

  puts "✔︎"
end

desc "JSON format examples"
task :format_examples do
  print "Formatting examples: "

  Dir.glob("examples/**/*.json").each do |example_path|
    print "."
    example = JSON.parse(File.read(example_path))
    pretty_json = JSON.pretty_generate(example)
    File.write(example_path, pretty_json + "\n")
  end

  puts "✔︎"
end

desc 'Validate uniqueness of frontend example base paths'
task :validate_uniqueness_of_frontend_example_base_paths, :files do |_, args|
  print "Checking that all frontend examples have unique base paths... "
  frontend_examples = args[:files] || Rake::FileList.new("formats/*/frontend/examples/*.json")
  grouped = frontend_examples.group_by { |file| base_path(file) }
  duplicates = grouped.select { |_, group| group.count > 1 }

  if duplicates.any?
    $stderr.puts "\n#{duplicates.count} duplicate(s) found:"

    duplicates.each do |_, group|
      group.each { |filename| $stderr.puts "  #{filename}" }
    end
    abort
  end
  puts "✔︎"
end

desc 'Validate links'
task :validate_links, :files do |_, args|
  print "Validating links... "
  link_schemas = args[:files] || Rake::FileList.new("formats/*/*/links.json")
  link_schemas.each do |filename|
    schema = JSON.parse(File.read(filename))
    if schema["required"]
      $stderr.puts "\nERROR: #{filename} has required links (#{schema["required"].inspect})"
      $stderr.puts "This is disallowed because the publishing-api wouldn't be able to validate partial payloads when sending a PATCH links request."
      abort
    end
  end
  puts "✔︎"
end
