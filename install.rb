def main
  puts "starting"
  install_each_dot_item_via_symlink
  puts "finished"

  display_report
end

def install_each_dot_item_via_symlink
  items_in_dot.each do |item|
    install_via_symlink(item)
  end
end

def display_report
  @report_messages.each{ |message| puts message }
end

def items_in_dot
  output = Dir.entries(path_to_dot).delete_if{ |item| item =~ /\A\./ }
end

def install_via_symlink(item)
  if correctly_installed_via_symlink?(item)
    report_already_installed(item)

  else
    backup_existing_home_item(item)
    create_simlink_for(item)

    if correctly_installed_via_symlink?(item)
      report_newly_installed(item)
    else
      report_message("could not install #{item}")
    end
  end
end

def correctly_installed_via_symlink?(item)
  File.exist?( home_path_for(item) ) && 
  File.symlink?( home_path_for(item) ) &&
  (
    File.absolute_path( File.readlink( home_path_for(item) ) ) ==
    File.absolute_path( dot_path_for(item) )
  )
end

def backup_existing_home_item(item)
  if File.exist?( home_path_for(item) )
    FileUtils.mv(
      home_path_for(item),
      home_path_for("#{item}.bak_by_dotfiles_install_#{timestamp}") 
    )
  end
end

def create_simlink_for(item)
  File.symlink(
    File.absolute_path( dot_path_for(item) ),
    File.absolute_path( home_path_for(item) )
  )
end

def timestamp
  @timestamp ||= Time.now.strftime("%Y-%m-%d_hms%H%M%S")
end

def home_path_for(item)
  File.join( ENV['HOME'], ".#{item}")
end

def report_already_installed(item)
  report_message( "already installed: #{describe_installation(item)}")
end

def report_newly_installed(item)
  report_message( "newly installed:   #{describe_installation(item)}")
end

def report_message(message)
  report_messages.push(message)
end

def report_messages
  @report_messages ||= []
end

def describe_installation(item)
  "#{tilde( home_path_for(item) )} -> #{tilde( dot_path_for(item) )}"
end

def tilde(path)
  File.absolute_path(path).gsub(ENV['HOME'], '~')
end

def dot_path_for(item)
  File.join(path_to_dot, item)
end

def path_to_dot
  File.join( File.dirname(__FILE__), '/dot' )
end



main


