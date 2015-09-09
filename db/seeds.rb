# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

[Tag, Image, Comment, Filter].each{|m| m.__elasticsearch__.create_index!}

tags_to_make = [{name: 'safe', system: true}, {name: 'questionable', system: true}, {name: 'explicit', system: true}]
for t_data in tags_to_make
  begin
    next if Tag.where(name: t_data[:name]).first rescue nil
    t = Tag.new
    t.update_attributes(t_data)
    t.set_namespaced_names
    t.set_slug
    t.save!
  rescue Exception => e
    puts "Couldn't create tag, already exists?"
    p e
  end
end
puts "Basic tags created"

begin
  user = User.new(name: 'Administrator', email: 'user@example.com', password: 'prettyplease', password_confirmation: 'prettyplease')
  user.downcase_name = 'administrator'
  user.save!
  puts 'New user created, login with email address "user@example.com" and password "prettyplease", and change these upon login.'
rescue Exception => e
  puts "Couldn't create admin user, already exists?"
  p e
end
