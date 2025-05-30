require 'xcodeproj'

# Open the project
project_path = 'HistoryDreams/HistoryDreams.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Get the main group
main_group = project.main_group['HistoryDreams']

# Get or create the Views group
views_group = main_group['Views'] || main_group.new_group('Views')

# Add files from each view directory
view_files = {
  'Components' => ['StoryRowView.swift'],
  'Home' => ['HomeView.swift'],
  'Library' => ['LibraryView.swift'],
  'Timer' => ['TimerView.swift'],
  'Settings' => ['SettingsView.swift']
}

view_files.each do |dir, files|
  # Get or create the directory group
  dir_group = views_group[dir] || views_group.new_group(dir)
  
  files.each do |file|
    # Add the file reference
    file_ref = dir_group.new_file("Views/#{dir}/#{file}")
    
    # Add to targets
    project.targets.first.add_file_references([file_ref])
  end
end

# Save the project
project.save 